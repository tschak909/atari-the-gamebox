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
            lda #.lo(WARNING)
            sta IOCB0+ICBAL,X
            lda #.hi(WARNING)
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
            jsr L082B
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
            jsr L0836
            jsr L081C
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
L07B3       jsr DSKINV
            inc DAUX1
            lda DBUFLO
            clc
            adc #$78
            sta DBUFLO
            lda DBUFHI
            adc #$00
            sta DBUFHI
            dec CNTLEN
            bne L07B3
            jsr L081C
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
L07E7       inc CNTLEN
            lda CNTLEN
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
            cmp MAXGAMES
            bcs L07E7
            sta MAXGAMES
            jsr L0943
            lda #$FF
            sta CH
            lda #$CA
            sta COLOR1
            bne L084F
L081C       lda SDLSTL
            sta TARGETBUF
            lda SDLSTH
            sta TARGETBUFH
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
            lda #.hi(END)
            sta TARGETBUFH
            sta DBUFHI
            lda #.lo(END)
            sta TARGETBUF
            sta DBUFLO
            rts
L084F       jsr L0836
            lda #$69
            sta DAUX1
            lda #$01
            sta DAUX2
            lda #$02
            sta CNTLEN
L0860       jsr DSKINV
            inc DAUX1
            lda DBUFLO
            clc
            adc #$80
            sta DBUFLO
            lda DBUFHI
            adc #$00
            sta DBUFHI
            dec CNTLEN
            bne L0860
            lda MAXGAMES
            tay
            beq L0890
L0880       clc
            lda TARGETBUF
            adc #$10
            sta TARGETBUF
            lda TARGETBUFH
            adc #$00
            sta TARGETBUFH
            dey
            bne L0880
L0890       ldy #$03
            lda (TARGETBUF),Y
            sta DAUX1
            iny
            lda (TARGETBUF),Y
            sta DAUX2
            jsr L0836
            jsr DSKINV
            ldy #$00
            jsr L0912
            bne L08AF
L08AA       jsr DSKINV
            ldy #$00
L08AF       jsr L0938
L08B2       lda (TARGETBUF),Y
            iny
            sty MAXGAMES
            ldy #$00
            sta (TARGET_ADDR),Y
            ldy MAXGAMES
            clc
            inc TARGET_ADDR
            bne L08C4
            inc TARGET_ADDRH
L08C4       lda ENDADDRH
            cmp TARGET_ADDRH
            bmi L08D3
            bne L08D9
            clc
            lda ENDADDRL
            cmp TARGET_ADDR
            bcs L08D9
L08D3       jsr L08F9
            jsr L0912
L08D9       cpy CNTLEN
            bcc L08B2
            ldy #$7D
            lda (TARGETBUF),Y
            and #$03
            sta DAUX2
            iny
            lda (TARGETBUF),Y
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
DEFINIT     rts
L0904       jmp (INITAD)
L0907       lda #.lo(DEFINIT)
            sta INITAD
            lda #.hi(DEFINIT)
            sta INITAD+1
            rts
L0912       lda (TARGETBUF),Y
            sta TARGET_ADDR
            iny
            lda (TARGETBUF),Y
            sta TARGET_ADDRH
            lda TARGET_ADDR
            cmp #$FF
            bne L092B
            lda TARGET_ADDRH
            cmp #$FF
            bne L092B
            iny
            tya
            bne L0912
L092B       iny
            lda (TARGETBUF),Y
            sta ENDADDRL
            iny
            lda (TARGETBUF),Y
            sta ENDADDRH
            iny
            tya
            rts
L0938       tya
            pha
            ldy #$7F
            lda (TARGETBUF),Y
            sta CNTLEN
            pla
            tay
            rts
L0943       tax
            inx
            jsr L081C
            ldy #$04
            lda (TARGETBUF),Y
            clc
            adc #$14
L094F       adc #$28
            sta TARGETBUF
            lda TARGETBUFH
            adc #$00
            sta TARGETBUFH
            clc
            lda TARGETBUF
            dex
            bne L094F
            ldy #$00
L0961       lda (TARGETBUF),Y
            beq L098A
            cmp #$20
            bcc L096D
            sbc #$C0
            bne L096F
L096D       adc #$80
L096F       sta (TARGETBUF),Y
            lda #$A5
            sta AUDC1
            lda #$B0
            sta CNTLEN
L097A       dec CNTLEN
            lda CNTLEN
            sta AUDF1
            beq L098A
            ldx #$60
            jsr L0827
            beq L097A
L098A       iny
            cpy #$14
            bne L0961
            rts
WARNING     .byte $7D
            .byte 'WARNING! REMOVE CARTRIDGE for some games'
            .byte $9B
SDEV        .byte 'S:'
TITLE       .byte 'S:<*> the game box <*>'
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
