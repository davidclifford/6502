ACIA := $FF70
ACIAControl := ACIA+0
ACIAStatus := ACIA+0
ACIAData := ACIA+1

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
