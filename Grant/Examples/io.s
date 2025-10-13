;IO_ECHO = $FF2A

ACIA := $A000
ACIAStatus := ACIA+0
ACIAData := ACIA+1

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
