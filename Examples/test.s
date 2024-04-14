DAVE .macro fred
    pha
    pla
    ldx #\fred
.endmacro

    .org $1000
start:
    lda #1
    DAVE 2
    rts
