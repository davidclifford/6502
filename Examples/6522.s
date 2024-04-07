IO_DATA = $c000
IO_STATUS = $c001
DDR_DATA = $c002
DDR_CTRL = $c003

RD = %00000001
WR = %00000010
TXE = %10000000
RXE = %01000000

    .org $1000

    LDA     #$FF                    ;
    STA     DDR_DATA                ; UART All output (default)
    LDA     #$03                    ;
    STA     DDR_CTRL                ; UART Ctrl pins [OI....RW] B1=Read B0=Write as output, UART Status B7=out B6=input as input

loop:
    ldx #0
wait:
    lda message,x  ; Set PORT A to next char
    beq loop
    jsr ECHO
    inx
    bra wait

ECHO:
    BIT     IO_STATUS               ; Wait for output to be ready
    BMI     ECHO
    STA     IO_DATA                 ; Output Character to UART
    LDA     #(WR|RD)                ; Set WR and RD to High
    STA     IO_STATUS
    LDA     #WR                     ; Write (active low)
    STA     IO_STATUS
    LDA     #(WR|RD)                ; Set WR and RD to High
    STA     IO_STATUS
    RTS                             ; Return.

message: .asciiz "The quick brown fox jumps over the lazy dog!",10
