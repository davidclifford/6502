; 830D -> 833D
; 834D
; 838D
; 83CD

; 840D

	.org $1000

plotptr = $80

start:
	lda #$83
	sta plotptr+1
vga_loop_2:
	lda #$0d
	sta plotptr
vga_loop_1:
	ldx #50
vga_loop_0:
    JSR RAND
    LDA XSHFT+1
	STA (plotptr)

	inc plotptr
	dex
	bne vga_loop_0

	lda plotptr
	clc
	adc #$0E
	sta plotptr
	bcc vga_loop_1

	inc plotptr+1
	lda plotptr+1
	cmp #$BF
	bne vga_loop_2
;	bra start
    RTS

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

XSHFT:  DW  $90

;    .include    "io.s"

