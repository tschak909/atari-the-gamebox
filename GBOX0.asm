;
            icl 'GBOX0.inc'
;
; Start of code
;
            org $0700
;
            ldy #$00
            sty COLDST          ; Clear coldstart flag
            clc
            rts
            iny
            sty BOOT            ; Reset boot flag
            jsr L08D9           ; Set INITAD to $F00F? (why?)

            lda #$01            ; hold on to $01 for AUX2
            pha

        ;; Close screen, to re-open

            ldx #$60            ; IOCB Channel #6
            lda #$0C            ; CIO CLOSE command
            sta IOCB0+ICCOM,X   ; Set command
            jsr CIOV            ; Call CIOV

        ;; Open screen again (GRAPHICS 1 + 16)

            ldx #$60            ; IOCB channel #6
            lda #$03            ; CIO OPEN command
            sta IOCB0+ICCOM,X
            lda #.lo(SDEV)      ; Buffer at $0962
            sta IOCB0+ICBAL,X
            lda #.hi(SDEV)
            sta IOCB0+ICBAH,X
            pla                 ; Fetch the $01 from above
            sta IOCB0+ICAX2,X   ; Set to ICAX2 (AUX2) (to set GRAPHICS 1)
            lda #$08
            sta IOCB0+ICAX1,X   ; Set ICAX1 to $08 (WRITE)
            jsr CIOV            ; Call CIOV

        ;; Place <*> the game box <*> title.

            lda #$09            ; $09 = PUT RECORD
            ldx #$60            ; IOCB Channel #6
            sta IOCB0+ICCOM,X   ; Set PUT RECORD into command
            jsr L07FD           ; Set Buffer length to 255 bytes (EOL will stop it)
            lda #.lo(TITLE)     ; Set Buffer to $0964
            sta IOCB0+ICBAL,X
            lda #.hi(TITLE)
            sta IOCB0+ICBAH,X
            jsr CIOV            ; Call CIOV to put to screen.

        ;; Place the SELECT NUMBER prompt at bottom.

            lda #.lo(SELECT)    ; SELECT NUMBER prompt at $0979
            sta IOCB0+ICBAL,X
            lda #.hi(SELECT)
            sta IOCB0+ICBAH,X
            lda #$17            ; set S: row to 23 ($17)
            sta ROWCRS
            jsr CIOV            ; Call CIOV

            jsr L0808           ; Set up SIOV to read into buffer at END

            jsr L07EE           ; Preserve shadow display list

        ;;  Load Title sector 1 ($016E) into display area

            ldy #$04            ; Scoot to LMS
            lda (TARGETBUF),Y       ; Load low byte of display area from dlist
            clc                 ; Clear carry
            adc #$3C            ; Add 60 (3 lines down)
            sta DBUFLO          ; Store into destination buffer address (LO)
            iny                 ; Increment and
            lda (TARGETBUF),Y       ; Get high byte of display area from dlist
            adc #$00
            sta DBUFHI          ; store into destination buffer address (HI)
            lda #$6E            ; Sector $016E
            sta DAUX1           ; Into DAUX1 and DAUX2
            lda #$01            ;
            sta DAUX2           ;
            lda #$03            ; set 3 as sector counter into $D0
            sta CNTLEN
L0785       jsr DSKINV          ; And call resident disk routine

        ;; Load next title sector ($016F+) into next display chunk

            inc DAUX1           ; Next sector
            lda DBUFLO          ; Get buffer address
            clc                 ;
            adc #$78            ; Add $78 (120)
            sta DBUFLO          ; to low buffer address
            lda DBUFHI          ; Increment DBUFHI if needed
            adc #$00            ;
            sta DBUFHI          ;
            dec CNTLEN           ; Decrement sector counter
            bne L0785           ; Repeat call to resident disk routine if not done.

        ;; Fetch the maximum # of games from loaded screen sectors

            jsr L07EE           ; Fetch display list address into $90
            inc TARGETBUFH           ; Increment high byte
            ldy #$C3            ; Scoot forward 195 bytes
            lda (TARGETBUF),Y       ; Fetch
            sta MAXGAMES           ; Store in $88
            lda #$00               ; Zero it out on screen...
            sta (TARGETBUF),Y      ; ...so we don't see it.

        ;; Clear audio and keyboard input

            lda #$00               ; This seems superfluous, but...
            sta AUDCTL             ; Zero out the audio control register.
            tax                    ; X<-A
            dex                    ; X = $FF
            stx CH                 ; Clear the Keyboard input character shadow register

        ;; Change GAME BOX color, and check for keyboard input

L07B9       inc CNTLEN          ; Increment temp counter
            lda CNTLEN          ; Load temp counter
            and #$F6            ; skip over brightest luminance
            sta COLOR1          ; Store into playfield color shadow register 1

            ldy #$28            ; y<-28, a modest delay
L07C4       jsr L07F9           ; Call delay
            dey                 ; y--
            bne L07C4           ; A bit more delay

            lda CH              ; Check key input
            cmp #$FF            ; Key not pressed?
            beq L07B9           ; yes, go back to L07C4
            jsr GETK            ; no, grab key pressed
            sec
            sbc #$31            ; Subtract ATASCII '1' to get binary value
            bcc L07B9           ; Go back if invalid value
            cmp MAXGAMES        ; Check against MAXGAMES
            bcs L07B9           ; Go back if greater than MAXGAMES
            sta MAXGAMES        ; Otherwise, re-use MAXGAMES as SELECTED GAME
            jsr L0915           ; Do selection laser ripple
            lda #$FF            ; a<-$FF
            sta CH              ; clear the keyboard shadow register.
            lda #$CA            ; Reset COLOR1 back to factory default.
            sta COLOR1          ;
            bne L0821           ; Unconditional jump to $0821

        ;; Save shadow display list ptr to TARGETBUF

L07EE       lda SDLSTL
            sta TARGETBUF
            lda SDLSTH
            sta TARGETBUFH
            rts

        ;; Simple delay counter

L07F9       dex
            bne L07F9
            rts

        ;; Set Buffer Length of IOCB X to 255 bytes
L07FD       lda #$FF            ; $FF = 255
            sta IOCB0+ICBLL,X   ; Set buffer length low
            lda #$00            ; $00
            sta IOCB0+ICBLH,X   ; Buffer Length High
            rts

        ;; Set up for SIO 'R'ead from D1:
        ;; into buffer at END

L0808       lda #$01            ; Unit 1
            sta DUNIT
            lda #$52            ; 'R'ead command
            sta DCOMND
            lda #.hi(END)            ; Set destination buffer to END
            sta TARGETBUFH           ; And keep a copy in ZP ($90) for indexing
            sta DBUFHI
            lda #.lo(END)
            sta TARGETBUF
            sta DBUFLO
            rts

        ;;
        ;; Start of the BINARY LOADer.
        ;; Read two directory sectors
        ;;

L0821       jsr L0808           ; Set up common disk read parameters
            lda #$69            ; sector $0169
            sta DAUX1           ;
            lda #$01            ;
            sta DAUX2           ;
            lda #$02            ; Check two disk sectors (because we have 9 files max)
            sta CNTLEN          ; into counter.
L0832       jsr DSKINV          ; Call resident disk handler
            inc DAUX1           ; Increment disk sector.
            lda DBUFLO          ; get current buffer address (LO)
            clc                 ; C<-0
            adc #$80            ; Add 128
            sta DBUFLO          ; Store
            lda DBUFHI          ; Load HI byte
            adc #$00            ; Deal with carry
            sta DBUFHI          ; store it.
            dec CNTLEN          ; Decrement temp counter.
            bne L0832           ; Do until temp counter is 0.

        ;; At this point, the DOS 2 directory is sitting at END in memory
        ;; Find the DOS 2 directory entry to get its starting sector.
        ;; This is solely based on the selected entry, so files in directory
        ;; are assumed to be in the same order as the menu.

            lda MAXGAMES        ; MAXGAMES = currently selected game - 1 (0 based)
            tay                 ; Y<-A
            beq L0862           ; if 0, no need to scoot to next directory entry, go to L0862
L0852       clc                 ; otherwise...
            lda TARGETBUF       ; get target buffer address (END)
            adc #$10            ; scoot forward by 16
            sta TARGETBUF       ; store back.
            lda TARGETBUFH      ; Get high byte
            adc #$00            ; Handle carry
            sta TARGETBUFH      ; store back.
            dey                 ; y--
            bne L0852           ; Loop if not done.
L0862       ldy #$03            ; Starting sector = +3
            lda (TARGETBUF),Y   ; Get low byte
            sta DAUX1           ; stuff into DAUX1
            iny                 ; y++
            lda (TARGETBUF),Y   ; get high byte
            sta DAUX2           ; Stuff into DAUX2
            jsr L0808           ; Set up common disk read parameters
            jsr DSKINV          ; Call resident disk handler to read sector
            ldy #$00            ; Reset Y to 0 for start of sector
            jsr L08E4           ; Go fetch segment addresses
            bne L0881           ; jump to L0881 if not at byte 0 in sector buffer.
L087C       jsr DSKINV          ; Otherwise get the next sector
            ldy #$00            ; Y = 0 (Y becomes relative to start of segment in buffer)
L0881       jsr L090A           ; Set CNTLEN to length of current file segment in sector.
L0884       lda (TARGETBUF),Y   ; Get next byte
            iny                 ; y++
            sty MAXGAMES        ; temporarily store in MAXGAMES.
            ldy #$00            ; Y=0
            sta (TARGET_ADDR),Y ; Store at TARGET_ADDR + y
            ldy MAXGAMES        ; Y=MAXGAMES
            clc                 ;
            inc TARGET_ADDR     ; Increment target address
            bne L0896           ; Skip to 0896 if we don't need to increment high
            inc TARGET_ADDRH    ; otherwise we increment high
L0896       lda ENDADDRH        ; Check end address high
            cmp TARGET_ADDRH    ; are we there?
            bmi L08A5           ; More than 127, go to 08A5
            bne L08AB           ; Not done yet, go to 08AB
            clc                 ;
            lda ENDADDRL        ; Check end address LO
            cmp TARGET_ADDR     ; Compare to target address
            bcs L08AB           ;
L08A5       jsr L08CB
            jsr L08E4
L08AB       cpy CNTLEN
            bcc L0884
            ldy #$7D
            lda (TARGETBUF),Y
            and #$03
            sta DAUX2
            iny
            lda (TARGETBUF),Y
            sta DAUX1
            bne L087C
            lda DAUX2
            bne L087C
            jmp (RUNAD)
            jmp (INITAD)
L08CB       tya
            pha
            jsr L08D6
            jsr L08D9
            pla
            tay
DEFINIT     rts

        ;; Jump to address at INITAD ($02E2)

L08D6       jmp (INITAD)

        ;; Reset INIT to an RTS address
        ;; This is an RTS in OSB, but needs to be
        ;; changed.

L08D9       lda #.lo(DEFINIT)
            sta INITAD
            lda #.hi(DEFINIT)
            sta INITAD+1
            rts

        ;; Fetch BINARY FILE start and end segments
        ;; From loaded disk sector buffer (TARGETBUF = END), and place
        ;; into TARGET_ADDR and ENDADDR
        ;; and then check for both end of page (lo byte $FF)
        ;; as well as hi byte being $FF, to indicate a binary file start marker.

L08E4       lda (TARGETBUF),Y   ; Get current byte
            sta TARGET_ADDR     ; store in TARGET_ADDR (LO byte)
            iny                 ; increment
            lda (TARGETBUF),Y   ; Get next byte
            sta TARGET_ADDRH    ; Store in TARGET_ADDRH (HI byte)
            lda TARGET_ADDR     ; Check target addr LO byte
            cmp #$FF            ; is it $FF?
            bne L08FD           ; Yes, go to L08FD
            lda TARGET_ADDRH    ; check target addr HI byte
            cmp #$FF            ; is HI byte $FF?
            bne L08FD           ; no, go to L08FD
            iny                 ; Next byte
            tya                 ; A<-Y
            bne L08E4           ; loop around if not 0.
L08FD       iny                 ; y++
            lda (TARGETBUF),Y   ; Get byte
            sta ENDADDRL        ; Store ending address (LO)
            iny                 ; y++
            lda (TARGETBUF),Y   ; Get byte
            sta ENDADDRH        ; Store ending address (HI)
            iny                 ; y++
            tya                 ; A<-Y
            rts                 ; done.

        ;; Get the length of the current sector in TARGETBUF
        ;; and place in CNTLEN.

L090A       tya                 ; Y<-A
            pha                 ; push A to stack
            ldy #$7F            ; +127 (end of sector buffer)
            lda (TARGETBUF),Y   ; Grab byte
            sta CNTLEN          ; store as length of data in next file segment
            pla                 ; pull stack back to A
            tay                 ; Y<-A
            rts                 ; Return to caller

        ;; This routine enters with A=Game number

L0915       tax                 ; X<-A
            inx                 ; x++
            jsr L07EE           ; Get display list address into TARGETBUF
            ldy #$04            ; Get screen address
            lda (TARGETBUF),Y   ; = $80
            clc                 ;
            adc #$14            ; Scoot forward to two lines before menu start

        ;; Loop X number of times until TARGETBUF points to selected game screen line

L0921       adc #$28            ; Go to next menu entry on screen
            sta TARGETBUF       ; $BDBC (top of menu display), store into pointer
            lda TARGETBUFH      ; Get high byte
            adc #$00            ; Handle carry
            sta TARGETBUFH      ; store high byte into target buffer pointer
            clc                 ;
            lda TARGETBUF       ; Load target buffer address again.
            dex                 ; x--
            bne L0921           ; Until we're done and are pointing to the right screen line.

        ;; Inverse each visible character, changing color, while
        ;; making a laser sound...

            ldy #$00            ; Start at beginning of line
L0933       lda (TARGETBUF),Y   ; Get next character
            beq L095C           ; If empty space, then skip
            cmp #$20            ; A number?
            bcc L093F           ; yes, go to L093F
            sbc #$C0            ; no, grab the other color
            bne L0941           ; Go to 0941 if not 0
L093F       adc #$80            ; shift character to color 0
L0941       sta (TARGETBUF),Y   ; store character on screen.

        ;; Laser sound setup

            lda #$A5            ; Set nice pure square at volume 5
            sta AUDC1           ; to audio channel 1
            lda #$B0            ; count down from $B0
            sta CNTLEN          ; store into counter

        ;; quickly upramp frequency, with small delay

L094C       dec CNTLEN          ; cntlen--
            lda CNTLEN          ; also use cntlen
            sta AUDF1           ; for frequency
            beq L095C           ; jump to L095C if zero
            ldx #$60            ; otherwise x<-$60
            jsr L07F9           ; Do a small delay.
            beq L094C           ; Continue if still ramping up.
L095C       iny                 ; Next character
            cpy #$14            ; Are we done?
            bne L0933           ; Nope, go back around.
            rts                 ; Otherwise, return.

SDEV        .byte 'S:'
TITLE       .byte '<*> the game box <*>'
            .byte $9B
SELECT      .byte '   SELECT NUMBER'
            .byte $9B
GETK	    LDA $E425
	    PHA
	    LDA $E424
	    PHA
	    RTS
;

END
