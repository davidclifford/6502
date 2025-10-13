ACIA := $FF70
ACIAControl := ACIA+0
ACIAStatus := ACIA+0
ACIAData := ACIA+1

    .org $1000
Start:
; Display startup message
	LDY #0
ShowStartMsg:
	LDA	StartupMessage,Y
	BEQ Start
	JSR	MONCOUT
	INY
	BRA	ShowStartMsg

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
