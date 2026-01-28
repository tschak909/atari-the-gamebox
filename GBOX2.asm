;
            icl 'GBOX2.inc'
;
; Start of code
;
            org $0700
;
            ldy #$00
            sty COLDST
            clc
            rts
            iny
            sty BOOT
            jsr L0911
            lda TRAMSZ
            beq L0745
            lda #$0A
            sta ROWCRS
            sta CRSINH
            ldx #$00
            stx COLCRS
            stx RTCLOK
            jsr L0835
            lda #$09
            sta IOCB0+ICCOM,X
            lda #.lo(REMOVE)
            sta IOCB0+ICBAL,X
            lda #.hi(REMOVE)
            sta IOCB0+ICBAH,X
            jsr CIOV
            lda #$32
            sta COLOR2
            sta COLOR4
L073B       bne L073B
            lda #$FF
            sta RTCLOK+1
L0741       lda RTCLOK+1
            bne L0741
L0745       lda #$01
            pha
            ldx #$60
            lda #$0C
            sta IOCB0+ICCOM,X
            jsr CIOV
            ldx #$60
            lda #$03
            sta IOCB0+ICCOM,X
            lda #.lo(SDEV)
            sta IOCB0+ICBAL,X
            lda #.hi(SDEV)
            sta IOCB0+ICBAH,X
            pla
            sta IOCB0+ICAX2,X
            lda #$08
            sta IOCB0+ICAX1,X
            jsr CIOV
            lda #$09
            ldx #$60
            sta IOCB0+ICCOM,X
            jsr L0835
            lda #.lo(TITLE)
            sta IOCB0+ICBAL,X
            lda #.hi(TITLE)
            sta IOCB0+ICBAH,X
            jsr CIOV
            lda #.lo(SELECT)
            sta IOCB0+ICBAL,X
            lda #.hi(SELECT)
            sta IOCB0+ICBAH,X
            lda #$17
            sta ROWCRS
            jsr CIOV
            jsr L0840
            jsr L0826
            ldy #$04
            lda (TARGETBUF),Y
            clc
            adc #$3C
            sta DBUFLO
            iny
            lda (TARGETBUF),Y
            adc #$00
            sta DBUFHI
            lda #$6E
            sta DAUX1
            lda #$01
            sta DAUX2
            lda #$03
            sta CNTLEN
L07BD       jsr DSKINV
            inc DAUX1
            lda DBUFLO
            clc
            adc #$78
            sta DBUFLO
            lda DBUFHI
            adc #$00
            sta DBUFHI
            dec CNTLEN
            bne L07BD
            jsr L0826
            inc TARGETBUFH
            ldy #$C3
            lda (TARGETBUF),Y
            sta MAXGAMES
            lda #$00
            sta (TARGETBUF),Y
            lda #$00
            sta AUDCTL
            tax
            dex
            stx CH
L07F1       inc CNTLEN
            lda CNTLEN
            and #$F6
            sta COLOR1
            ldy #$28
L07FC       jsr L0831
            dey
            bne L07FC
            lda CH
            cmp #$FF
            beq L07F1
            jsr GETK
            sec
            sbc #$31
            bcc L07F1
            cmp MAXGAMES
            bcs L07F1
            sta MAXGAMES
            jsr L094D
            lda #$FF
            sta CH
            lda #$CA
            sta COLOR1
            bne L0859
L0826       lda SDLSTL
            sta TARGETBUF
            lda SDLSTH
            sta TARGETBUFH
            rts
L0831       dex
            bne L0831
            rts
L0835       lda #$FF
            sta IOCB0+ICBLL,X
            lda #$00
            sta IOCB0+ICBLH,X
            rts
L0840       lda #$01
            sta DUNIT
            lda #$52
            sta DCOMND
            lda #.hi(END)
            sta TARGETBUFH
            sta DBUFHI
            lda #.lo(END)
            sta TARGETBUF
            sta DBUFLO
            rts
L0859       jsr L0840
            lda #$69
            sta DAUX1
            lda #$01
            sta DAUX2
            lda #$02
            sta CNTLEN
L086A       jsr DSKINV
            inc DAUX1
            lda DBUFLO
            clc
            adc #$80
            sta DBUFLO
            lda DBUFHI
            adc #$00
            sta DBUFHI
            dec CNTLEN
            bne L086A
            lda MAXGAMES
            tay
            beq L089A
L088A       clc
            lda TARGETBUF
            adc #$10
            sta TARGETBUF
            lda TARGETBUFH
            adc #$00
            sta TARGETBUFH
            dey
            bne L088A
L089A       ldy #$03
            lda (TARGETBUF),Y
            sta DAUX1
            iny
            lda (TARGETBUF),Y
            sta DAUX2
            jsr L0840
            jsr DSKINV
            ldy #$00
            jsr L091C
            bne L08B9
L08B4       jsr DSKINV
            ldy #$00
L08B9       jsr L0942
L08BC       lda (TARGETBUF),Y
            iny
            sty MAXGAMES
            ldy #$00
            sta (TARGET_ADDR),Y
            ldy MAXGAMES
            clc
            inc TARGET_ADDR
            bne L08CE
            inc TARGET_ADDRH
L08CE       lda ENDADDRH
            cmp TARGET_ADDRH
            bmi L08DD
            bne L08E3
            clc
            lda ENDADDRL
            cmp TARGET_ADDR
            bcs L08E3
L08DD       jsr L0903
            jsr L091C
L08E3       cpy CNTLEN
            bcc L08BC
            ldy #$7D
            lda (TARGETBUF),Y
            and #$03
            sta DAUX2
            iny
            lda (TARGETBUF),Y
            sta DAUX1
            bne L08B4
            lda DAUX2
            bne L08B4
            jmp (RUNAD)
            jmp (INITAD)
L0903       tya
            pha
            jsr L090E
            jsr L0911
            pla
            tay
DEFINIT     rts
L090E       jmp (INITAD)
L0911       lda #.lo(DEFINIT)
            sta INITAD
            lda #.hi(DEFINIT)
            sta INITAD+1
            rts
L091C       lda (TARGETBUF),Y
            sta TARGET_ADDR
            iny
            lda (TARGETBUF),Y
            sta TARGET_ADDRH
            lda TARGET_ADDR
            cmp #$FF
            bne L0935
            lda TARGET_ADDRH
            cmp #$FF
            bne L0935
            iny
            tya
            bne L091C
L0935       iny
            lda (TARGETBUF),Y
            sta ENDADDRL
            iny
            lda (TARGETBUF),Y
            sta ENDADDRH
            iny
            tya
            rts
L0942       tya
            pha
            ldy #$7F
            lda (TARGETBUF),Y
            sta CNTLEN
            pla
            tay
            rts
L094D       tax
            inx
            jsr L0826
            ldy #$04
            lda (TARGETBUF),Y
            clc
            adc #$14
L0959       adc #$28
            sta TARGETBUF
            lda TARGETBUFH
            adc #$00
            sta TARGETBUFH
            clc
            lda TARGETBUF
            dex
            bne L0959
            ldy #$00
L096B       lda (TARGETBUF),Y
            beq L0994
            cmp #$20
            bcc L0977
            sbc #$C0
            bne L0979
L0977       adc #$80
L0979       sta (TARGETBUF),Y
            lda #$A5
            sta AUDC1
            lda #$B0
            sta CNTLEN
L0984       dec CNTLEN
            lda CNTLEN
            sta AUDF1
            beq L0994
            ldx #$60
            jsr L0831
            beq L0984
L0994       iny
            cpy #$14
            bne L096B
            rts
REMOVE      .byte $7D
            .byte '     R E M O V E   C A R T R I D G E '
            .byte $9B
SDEV        .byte 'S:'
TITLE       .byte '<*> the game box <*>'
            .byte $9B
SELECT      .byte '   SELECT NUMBER'
            .byte $9B
;

GETK	    LDA $E425
            PHA
            LDA $E424
            PHA
            RTS

END
