    ; Mandelbrot using ascii
    .org $1000

    ; Start
    lda #10
    jsr IO_ECHO

    ldy #0
loopy:
    ldx #0
loopx:
    jsr mand_get
    adc #'!'
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
    jmp $c100

char_codes : .string ' .:-=x+*&$#X%8@ZZZZZZ'

    .include mandel.s
    .include io.s

