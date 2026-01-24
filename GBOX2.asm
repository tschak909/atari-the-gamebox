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
            lda #$9A
            sta IOCB0+ICBAL,X
            lda #$09
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
            lda #$C1
            sta IOCB0+ICBAL,X
            lda #$09
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
            lda #$C3
            sta IOCB0+ICBAL,X
            lda #$09
            sta IOCB0+ICBAH,X
            jsr CIOV
            lda #$D8
            sta IOCB0+ICBAL,X
            lda #$09
            sta IOCB0+ICBAH,X
            lda #$17
            sta ROWCRS
            jsr CIOV
            jsr L0840
            jsr L0826
            ldy #$04
            lda (L0090),Y
            clc
            adc #$3C
            sta DBUFLO
            iny
            lda (L0090),Y
            adc #$00
            sta DBUFHI
            lda #$6E
            sta DAUX1
            lda #$01
            sta DAUX2
            lda #$03
            sta L00D0
L07BD       jsr DSKINV
            inc DAUX1
            lda DBUFLO
            clc
            adc #$78
            sta DBUFLO
            lda DBUFHI
            adc #$00
            sta DBUFHI
            dec L00D0
            bne L07BD
            jsr L0826
            inc L0091
            ldy #$C3
            lda (L0090),Y
            sta L0088
            lda #$00
            sta (L0090),Y
            lda #$00
            sta AUDCTL
            tax
            dex
            stx CH
L07F1       inc L00D0
            lda L00D0
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
            cmp L0088
            bcs L07F1
            sta L0088
            jsr L094D
            lda #$FF
            sta CH
            lda #$CA
            sta COLOR1
            bne L0859
L0826       lda SDLSTL
            sta L0090
            lda SDLSTH
            sta L0091
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
            lda #$09
            sta L0091
            sta DBUFHI
            lda #$E9
            sta L0090
            sta DBUFLO
            rts
L0859       jsr L0840
            lda #$69
            sta DAUX1
            lda #$01
            sta DAUX2
            lda #$02
            sta L00D0
L086A       jsr DSKINV
            inc DAUX1
            lda DBUFLO
            clc
            adc #$80
            sta DBUFLO
            lda DBUFHI
            adc #$00
            sta DBUFHI
            dec L00D0
            bne L086A
            lda L0088
            tay
            beq L089A
L088A       clc
            lda L0090
            adc #$10
            sta L0090
            lda L0091
            adc #$00
            sta L0091
            dey
            bne L088A
L089A       ldy #$03
            lda (L0090),Y
            sta DAUX1
            iny
            lda (L0090),Y
            sta DAUX2
            jsr L0840
            jsr DSKINV
            ldy #$00
            jsr L091C
            bne L08B9
L08B4       jsr DSKINV
            ldy #$00
L08B9       jsr L0942
L08BC       lda (L0090),Y
            iny
            sty L0088
            ldy #$00
            sta (L00CC),Y
            ldy L0088
            clc
            inc L00CC
            bne L08CE
            inc L00CD
L08CE       lda L00CF
            cmp L00CD
            bmi L08DD
            bne L08E3
            clc
            lda L00CE
            cmp L00CC
            bcs L08E3
L08DD       jsr L0903
            jsr L091C
L08E3       cpy L00D0
            bcc L08BC
            ldy #$7D
            lda (L0090),Y
            and #$03
            sta DAUX2
            iny
            lda (L0090),Y
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
            rts
L090E       jmp (INITAD)
L0911       lda #$0F
            sta INITAD
            lda #$F0
            sta INITAD+1
            rts
L091C       lda (L0090),Y
            sta L00CC
            iny
            lda (L0090),Y
            sta L00CD
            lda L00CC
            cmp #$FF
            bne L0935
            lda L00CD
            cmp #$FF
            bne L0935
            iny
            tya
            bne L091C
L0935       iny
            lda (L0090),Y
            sta L00CE
            iny
            lda (L0090),Y
            sta L00CF
            iny
            tya
            rts
L0942       tya
            pha
            ldy #$7F
            lda (L0090),Y
            sta L00D0
            pla
            tay
            rts
L094D       tax
            inx
            jsr L0826
            ldy #$04
            lda (L0090),Y
            clc
            adc #$14
L0959       adc #$28
            sta L0090
            lda L0091
            adc #$00
            sta L0091
            clc
            lda L0090
            dex
            bne L0959
            ldy #$00
L096B       lda (L0090),Y
            beq L0994
            cmp #$20
            bcc L0977
            sbc #$C0
            bne L0979
L0977       adc #$80
L0979       sta (L0090),Y
            lda #$A5
            sta AUDC1
            lda #$B0
            sta L00D0
L0984       dec L00D0
            lda L00D0
            sta AUDF1
            beq L0994
            ldx #$60
            jsr L0831
            beq L0984
L0994       iny
            cpy #$14
            bne L096B
            rts
            .byte $7D
            .byte '     R E M O V E   C A R T R I D G E '
            .byte $9B
            .byte 'S:<*> the game box <*>'
            .byte $9B
            .byte '   SELECT NUMBER'
            .byte $9B
;

GETK	    LDA $E425
            PHA
            LDA $E424
            PHA
            RTS
