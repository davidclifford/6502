    ; Mandelbrot using Matt Heffernan's algorithm
    .org $1000

    ; Start
    lda #10
    jsr IO_ECHO

    ldy #0
loopy:
    ldx #0
loopx:
    jsr mand_get
    clc
    adc #' '
    jsr IO_ECHO
    jsr IO_ECHO
    inx
    cpx #MAND_WIDTH
    bne loopx
    lda #10
    jsr IO_ECHO
    iny
    cpy #MAND_HEIGHT
    bne loopy
    lda #10
    jsr IO_ECHO
    rts

    .include io.s
    .include mandel.s
