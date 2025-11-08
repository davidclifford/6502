    ; Mandelbrot using Matt Heffernan's algorithm

vga_ptr = $20

    .org $1000

    ; Start
    ldy #0
loopy:
    ldx #0
loopx:
    stx vga_ptr
    tya
    ora #$80
    sta vga_ptr+1
    jsr mand_get
    sta (vga_ptr)
    inx
    cpx #MAND_WIDTH
    bne loopx
    iny
    cpy #MAND_HEIGHT
    bne loopy
    rts

    .include io.s
    .include mandel.s
