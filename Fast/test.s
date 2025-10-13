ACIA := $FF70
ACIAControl := ACIA+0
ACIAStatus := ACIA+0
ACIAData := ACIA+1

    .org $8000
    .org $F000
Reset:
	LDX     #0
	TXS

	LDA 	#$95		; Set ACIA baud rate, word size and Rx interrupt (to control RTS)
	STA	ACIAControl
Start:
; Display startup message
	LDY #0
ShowStartMsg:
	LDA	StartupMessage,Y
	JSR	MONCOUT
	INY
	BNE	ShowStartMsg
    BRA Start

MONCOUT:
	PHA
SerialOutWait:
	LDA	ACIAStatus
	AND	#2
	CMP	#2
	BNE	SerialOutWait
	PLA
	STA	ACIAData
	RTS

StartupMessage:
	.byte	$0C,"Hello, World!",$0D,$0A,$00

    .org    $FFFA                       ; ---VECTORS---
    .word   Reset                       ; NMI vector
    .word   Reset                       ; RESET vector
    .word   $0000                       ; IRQ vector
