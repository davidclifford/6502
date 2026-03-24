	.org $1100

plotptr = $80

start:
	lda #$80
	sta plotptr+1
	lda #$00
	sta plotptr
	LDA #$FF
	STA (plotptr)
	RTS
