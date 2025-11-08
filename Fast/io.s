ACIA := $FF70
ACIAControl := ACIA+0
ACIAStatus := ACIA+0
ACIAData := ACIA+1

printptr = $80

; Output character in A and return.
IO_ECHO:
	PHA
SerialOutWait:
	LDA	ACIAStatus
	AND	#2
	CMP	#2
	BNE	SerialOutWait
	PLA
	STA	ACIAData
	RTS

IO_IMM:
	pha
    phx
    phy

	tsx
	clc
	lda $0104,x
    adc #1
    sta printptr
	lda $0105,x
    adc #0
    sta printptr+1

	jsr printmsgloop

	lda printptr
    sta $0104,x
	lda printptr+1
    sta $0105,x

	ply
    plx
    pla
	rts

printmsgloop:
	ldy #0
	lda (printptr),y
	beq endprintmsgloop
	jsr IO_ECHO
	inc printptr
	bne printmsgloop
	inc printptr+1
	bra printmsgloop

endprintmsgloop:
	rts


; Wait for key and return code in A
IO_KEY:
    LDA	    ACIAStatus
    AND	    #1
    CMP	    #1
    BNE     IO_KEY
    LDA	    ACIAData
    RTS

; Get next key press in A and set Carry.
; If no key then clear carry and return zero in A.
IO_INKEY:
    LDA	    ACIAStatus
    AND	    #1
    CMP	    #1
    BNE     NoKey
    LDA	    ACIAData
    SEC
    RTS
NoKey:
    LDA     #0
    CLC
    RTS

VGA_CLR:
	lda #$80
	sta printptr+1
	stz printptr
vga_clr_loop:
	lda #0
	sta (printptr)
	inc printptr
	bne vga_clr_loop
	inc printptr+1
	lda printptr+1
	cmp #248
	bne vga_clr_loop

	rts
