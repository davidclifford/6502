        .org $1000

        LDA     #10
        JSR     IO_ECHO
LOOP:
        JSR     RAND
        LDA     XSHFT+1
        BMI     BS
        LDA     #'/'
        JSR     IO_ECHO
        BRA     LOOP
BS:
        LDA     #'\'
        JSR     IO_ECHO
        BRA     LOOP

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

XSHFT:  DW     $1234

        .include    "io.s"
