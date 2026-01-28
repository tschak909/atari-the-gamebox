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
            lda (L0090),Y       ; Load low byte of display area from dlist
            clc                 ; Clear carry
            adc #$3C            ; Add 60 (3 lines down)
            sta DBUFLO          ; Store into destination buffer address (LO)
            iny                 ; Increment and
            lda (L0090),Y       ; Get high byte of display area from dlist
            adc #$00
            sta DBUFHI          ; store into destination buffer address (HI)
            lda #$6E            ; Sector $016E
            sta DAUX1           ; Into DAUX1 and DAUX2
            lda #$01            ;
            sta DAUX2           ;
            lda #$03            ; set 3 as sector counter into $D0
            sta L00D0
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
            dec L00D0           ; Decrement sector counter
            bne L0785           ; Repeat call to resident disk routine if not done.

            jsr L07EE           ; Fetch display list address into $90
            inc L0091           ; Increment high byte
            ldy #$C3            ; 195 bytes
            lda (L0090),Y       ; Fetch
            sta L0088           ; Store in $88
            lda #$00
            sta (L0090),Y
            lda #$00
            sta AUDCTL
            tax
            dex
            stx CH
L07B9       inc L00D0
            lda L00D0
            and #$F6
            sta COLOR1
            ldy #$28
L07C4       jsr L07F9
            dey
            bne L07C4
            lda CH
            cmp #$FF
            beq L07B9
            jsr GETK
            sec
            sbc #$31
            bcc L07B9
            cmp L0088
            bcs L07B9
            sta L0088
            jsr L0915
            lda #$FF
            sta CH
            lda #$CA
            sta COLOR1
            bne L0821

        ;; Save shadow display list ptr at ZP $(90)

L07EE       lda SDLSTL
            sta L0090
            lda SDLSTH
            sta L0091
            rts

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
            sta L0091           ; And keep a copy in ZP ($90) for indexing
            sta DBUFHI
            lda #.lo(END)
            sta L0090
            sta DBUFLO
            rts

L0821       jsr L0808
            lda #$69
            sta DAUX1
            lda #$01
            sta DAUX2
            lda #$02
            sta L00D0
L0832       jsr DSKINV
            inc DAUX1
            lda DBUFLO
            clc
            adc #$80
            sta DBUFLO
            lda DBUFHI
            adc #$00
            sta DBUFHI
            dec L00D0
            bne L0832
            lda L0088
            tay
            beq L0862
L0852       clc
            lda L0090
            adc #$10
            sta L0090
            lda L0091
            adc #$00
            sta L0091
            dey
            bne L0852
L0862       ldy #$03
            lda (L0090),Y
            sta DAUX1
            iny
            lda (L0090),Y
            sta DAUX2
            jsr L0808
            jsr DSKINV
            ldy #$00
            jsr L08E4
            bne L0881
L087C       jsr DSKINV
            ldy #$00
L0881       jsr L090A
L0884       lda (L0090),Y
            iny
            sty L0088
            ldy #$00
            sta (L00CC),Y
            ldy L0088
            clc
            inc L00CC
            bne L0896
            inc L00CD
L0896       lda L00CF
            cmp L00CD
            bmi L08A5
            bne L08AB
            clc
            lda L00CE
            cmp L00CC
            bcs L08AB
L08A5       jsr L08CB
            jsr L08E4
L08AB       cpy L00D0
            bcc L0884
            ldy #$7D
            lda (L0090),Y
            and #$03
            sta DAUX2
            iny
            lda (L0090),Y
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
            rts
L08D6       jmp (INITAD)
L08D9       lda #$0F
            sta INITAD
            lda #$F0
            sta INITAD+1
            rts
L08E4       lda (L0090),Y
            sta L00CC
            iny
            lda (L0090),Y
            sta L00CD
            lda L00CC
            cmp #$FF
            bne L08FD
            lda L00CD
            cmp #$FF
            bne L08FD
            iny
            tya
            bne L08E4
L08FD       iny
            lda (L0090),Y
            sta L00CE
            iny
            lda (L0090),Y
            sta L00CF
            iny
            tya
            rts
L090A       tya
            pha
            ldy #$7F
            lda (L0090),Y
            sta L00D0
            pla
            tay
            rts
L0915       tax
            inx
            jsr L07EE
            ldy #$04
            lda (L0090),Y
            clc
            adc #$14
L0921       adc #$28
            sta L0090
            lda L0091
            adc #$00
            sta L0091
            clc
            lda L0090
            dex
            bne L0921
            ldy #$00
L0933       lda (L0090),Y
            beq L095C
            cmp #$20
            bcc L093F
            sbc #$C0
            bne L0941
L093F       adc #$80
L0941       sta (L0090),Y
            lda #$A5
            sta AUDC1
            lda #$B0
            sta L00D0
L094C       dec L00D0
            lda L00D0
            sta AUDF1
            beq L095C
            ldx #$60
            jsr L07F9
            beq L094C
L095C       iny
            cpy #$14
            bne L0933
            rts
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
