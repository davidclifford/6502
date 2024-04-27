    .org $1000

    lda #01
    clc
loop:
    sta $0010
    eor #$FF
    sta $0018
    eor #$FF
    rol
    ldy #0
wait2:
    ldx #0
wait:
    inx
    bne wait
    iny
    bne wait2
    bra loop
