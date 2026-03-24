	.org $2000

plotptr = $80
col=$A0
row=$A1

start:
	stz row
	stz col
	lda #$80
	sta plotptr+1
	stz plotptr

vga_clr_loop0:
	lda #0
	STA (plotptr)

	inc plotptr
	bne vga_clr_loop0
	inc plotptr+1
	lda plotptr+1
	cmp #$C0
	bne vga_clr_loop0
    RTS
