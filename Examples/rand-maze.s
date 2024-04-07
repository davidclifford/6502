        .org $1000

        JSR     IO_INIT
LOOP:
        JSR     RAND
        LDA     XSHFT
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
