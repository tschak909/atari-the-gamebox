;
            icl 'GBOX1.inc'
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
            jsr L0907
            lda TRAMSZ
            beq L073B
            lda #$0A
            sta ROWCRS
            sta CRSINH
            ldx #$00
            stx COLCRS
            stx RTCLOK
            jsr L082B
            lda #$09
            sta IOCB0+ICCOM,X
            lda #$90
            sta IOCB0+ICBAL,X
            lda #$09
            sta IOCB0+ICBAH,X
            jsr CIOV
            lda #$FF
            sta RTCLOK+1
L0737       lda RTCLOK+1
            bne L0737
L073B       lda #$01
            pha
            ldx #$60
            lda #$0C
            sta IOCB0+ICCOM,X
            jsr CIOV
            ldx #$60
            lda #$03
            sta IOCB0+ICCOM,X
            lda #$BA
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
            jsr L082B
            lda #$BC
            sta IOCB0+ICBAL,X
            lda #$09
            sta IOCB0+ICBAH,X
            jsr CIOV
            lda #$D1
            sta IOCB0+ICBAL,X
            lda #$09
            sta IOCB0+ICBAH,X
            lda #$17
            sta ROWCRS
            jsr CIOV
            jsr L0836
            jsr L081C
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
L07B3       jsr DSKINV
            inc DAUX1
            lda DBUFLO
            clc
            adc #$78
            sta DBUFLO
            lda DBUFHI
            adc #$00
            sta DBUFHI
            dec L00D0
            bne L07B3
            jsr L081C
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
L07E7       inc L00D0
            lda L00D0
            and #$F6
            sta COLOR1
            ldy #$28
L07F2       jsr L0827
            dey
            bne L07F2
            lda CH
            cmp #$FF
            beq L07E7
            jsr GETK
            sec
            sbc #$31
            bcc L07E7
            cmp L0088
            bcs L07E7
            sta L0088
            jsr L0943
            lda #$FF
            sta CH
            lda #$CA
            sta COLOR1
            bne L084F
L081C       lda SDLSTL
            sta L0090
            lda SDLSTH
            sta L0091
            rts
L0827       dex
            bne L0827
            rts
L082B       lda #$FF
            sta IOCB0+ICBLL,X
            lda #$00
            sta IOCB0+ICBLH,X
            rts
L0836       lda #$01
            sta DUNIT
            lda #$52
            sta DCOMND
            lda #$09
            sta L0091
            sta DBUFHI
            lda #$E2
            sta L0090
            sta DBUFLO
            rts
L084F       jsr L0836
            lda #$69
            sta DAUX1
            lda #$01
            sta DAUX2
            lda #$02
            sta L00D0
L0860       jsr DSKINV
            inc DAUX1
            lda DBUFLO
            clc
            adc #$80
            sta DBUFLO
            lda DBUFHI
            adc #$00
            sta DBUFHI
            dec L00D0
            bne L0860
            lda L0088
            tay
            beq L0890
L0880       clc
            lda L0090
            adc #$10
            sta L0090
            lda L0091
            adc #$00
            sta L0091
            dey
            bne L0880
L0890       ldy #$03
            lda (L0090),Y
            sta DAUX1
            iny
            lda (L0090),Y
            sta DAUX2
            jsr L0836
            jsr DSKINV
            ldy #$00
            jsr L0912
            bne L08AF
L08AA       jsr DSKINV
            ldy #$00
L08AF       jsr L0938
L08B2       lda (L0090),Y
            iny
            sty L0088
            ldy #$00
            sta (L00CC),Y
            ldy L0088
            clc
            inc L00CC
            bne L08C4
            inc L00CD
L08C4       lda L00CF
            cmp L00CD
            bmi L08D3
            bne L08D9
            clc
            lda L00CE
            cmp L00CC
            bcs L08D9
L08D3       jsr L08F9
            jsr L0912
L08D9       cpy L00D0
            bcc L08B2
            ldy #$7D
            lda (L0090),Y
            and #$03
            sta DAUX2
            iny
            lda (L0090),Y
            sta DAUX1
            bne L08AA
            lda DAUX2
            bne L08AA
            jmp (RUNAD)
            jmp (INITAD)
L08F9       tya
            pha
            jsr L0904
            jsr L0907
            pla
            tay
            rts
L0904       jmp (INITAD)
L0907       lda #$0F
            sta INITAD
            lda #$F0
            sta INITAD+1
            rts
L0912       lda (L0090),Y
            sta L00CC
            iny
            lda (L0090),Y
            sta L00CD
            lda L00CC
            cmp #$FF
            bne L092B
            lda L00CD
            cmp #$FF
            bne L092B
            iny
            tya
            bne L0912
L092B       iny
            lda (L0090),Y
            sta L00CE
            iny
            lda (L0090),Y
            sta L00CF
            iny
            tya
            rts
L0938       tya
            pha
            ldy #$7F
            lda (L0090),Y
            sta L00D0
            pla
            tay
            rts
L0943       tax
            inx
            jsr L081C
            ldy #$04
            lda (L0090),Y
            clc
            adc #$14
L094F       adc #$28
            sta L0090
            lda L0091
            adc #$00
            sta L0091
            clc
            lda L0090
            dex
            bne L094F
            ldy #$00
L0961       lda (L0090),Y
            beq L098A
            cmp #$20
            bcc L096D
            sbc #$C0
            bne L096F
L096D       adc #$80
L096F       sta (L0090),Y
            lda #$A5
            sta AUDC1
            lda #$B0
            sta L00D0
L097A       dec L00D0
            lda L00D0
            sta AUDF1
            beq L098A
            ldx #$60
            jsr L0827
            beq L097A
L098A       iny
            cpy #$14
            bne L0961
            rts
            .byte $7D
            .byte 'WARNING! REMOVE CARTRIDGE for some games'
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
