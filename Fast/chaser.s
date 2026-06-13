    .org $1000

loop:
    jsr RAND
    sta $FF00
    ldy #0
wait2:
    ldx #0
wait:
    inx
    bne wait
    iny
    bne wait2
    bra loop

RAND:
        LDA     XSHFT+1
        ROR
        LDA     XSHFT
        ROR
        EOR     XSHFT+1
        STA     XSHFT+1
        ROR
        EOR     XSHFT
        STA     XSHFT
        EOR     XSHFT+1
        STA     XSHFT+1
        RTS

XSHFT:  DW     $1234
