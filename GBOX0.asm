; 
            icl 'GBOX0.inc'
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
            jsr L08D9
            lda #$01
            pha
            ldx #$60
            lda #$0C
            sta IOCB0+ICCOM,X
            jsr CIOV
            ldx #$60
            lda #$03
            sta IOCB0+ICCOM,X
            lda #$62
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
            jsr L07FD
            lda #$64
            sta IOCB0+ICBAL,X
            lda #$09
            sta IOCB0+ICBAH,X
            jsr CIOV
            lda #$79
            sta IOCB0+ICBAL,X
            lda #$09
            sta IOCB0+ICBAH,X
            lda #$17
            sta ROWCRS
            jsr CIOV
            jsr L0808
            jsr L07EE
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
L0785       jsr DSKINV
            inc DAUX1
            lda DBUFLO
            clc
            adc #$78
            sta DBUFLO
            lda DBUFHI
            adc #$00
            sta DBUFHI
            dec L00D0
            bne L0785
            jsr L07EE
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
L07EE       lda SDLSTL
            sta L0090
            lda SDLSTH
            sta L0091
            rts
L07F9       dex
            bne L07F9
            rts
L07FD       lda #$FF
            sta IOCB0+ICBLL,X
            lda #$00
            sta IOCB0+ICBLH,X
            rts
L0808       lda #$01
            sta DUNIT
            lda #$52
            sta DCOMND
            lda #$09
            sta L0091
            sta DBUFHI
            lda #$8A
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
            .byte 'S:<*> the game box <*>'
            .byte $9B
            .byte '   SELECT NUMBER'
            .byte $9B
GETK	    LDA $E425
	    PHA
	    LDA $E424
	    PHA
	    RTS
;
         
