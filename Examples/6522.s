IO_DATA = $c000
IO_STATUS = $c001
IO_DDR_DATA = $c002
IO_DDR_CTRL = $c003

IO_RD = %00000001
IO_WR = %00000010
TXE = %10000000
RXE = %01000000

    .org $1000

    LDA     #$FF                    ;
    STA IO_DDR_DATA                 ; UART All output (default)
    LDA     #$03                    ;
    STA IO_DDR_CTRL                 ; UART Ctrl pins [OI....RW] B1=Read B0=Write as output, UART Status B7=out B6=input as input

loop:
    ldx #0
wait:
    lda message,x                   ; Set PORT A to next char
    beq loop
    jsr ECHO
    inx
    bra wait

ECHO:
    BIT     IO_STATUS               ; Wait for output to be ready
    BMI     ECHO
    STA     IO_DATA                 ; Output Character to UART
    LDA     #(IO_WR|IO_RD)          ; Set WR and RD to High
    STA     IO_STATUS
    LDA     #IO_WR                  ; Write (active low)
    STA     IO_STATUS
    LDA     #(IO_WR|IO_RD)          ; Set WR and RD to High
    STA     IO_STATUS
    RTS                             ; Return.

message: .asciiz "The quick brown fox jumps over the lazy dog! The quick brown fox jumps over the lazy dog! The quick brown fox jumps over the lazy dog! The quick brown fox jumps over the lazy dog!",10
