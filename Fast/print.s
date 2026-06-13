    .org $3000

count=$95

start:
	lda #10
	sta count
again:
    lda #0
	tax
next:
	lda mess,x
	cmp #0
	beq fin
	jsr putchar
	inx
	bra next
fin:
	dec count
	bne again
;	bra again
	rts

mess:
;	db "Pack my box with five dozen liquor jugs? The quick brown fox jumps over the lazy dog! "
	db "1234567890!@#$%^&*()-_=+[{]};:',<.>/?`~",34,127
	db "qwertyuiopasdfghjklzxcvbnm QWERTYUIOPASDFGHJKLZXCVBNM", 0

	.include putchar.s
