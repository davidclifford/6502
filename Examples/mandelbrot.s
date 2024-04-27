    ; Mandelbrot using ascii
    .org $1000

    ; Start
    lda #10
    jsr IO_ECHO

    ldy #0
loopy:
    ldx #0
loopx:
    lda #27
    jsr IO_ECHO
    lda #'['
    jsr IO_ECHO

    jsr mand_get
    sta $90
    bbs3 $90,lighter

    lda #'4'
    jsr IO_ECHO
    lda $90
    bra square
lighter:
    lda #'1'
    jsr IO_ECHO
    lda #'0'
    jsr IO_ECHO
    lda $90
    inc
square:
    and #7
    clc
    adc #'0'
    jsr IO_ECHO

    lda #'m'
    jsr IO_ECHO
    lda #' '
    jsr IO_ECHO
    lda #' '
    jsr IO_ECHO
    inx
    cpx #MAND_WIDTH
    bne loopx
    lda #27
    jsr IO_ECHO
    lda #'['
    jsr IO_ECHO
    lda #'4'
    jsr IO_ECHO
    lda #'0'
    jsr IO_ECHO
    lda #'m'
    jsr IO_ECHO
    lda #10
    jsr IO_ECHO
    iny
    cpy #MAND_HEIGHT
    bne loopy
    lda #10
    jsr IO_ECHO
    jmp $c100

    .include io.s
    .include mandel.s
