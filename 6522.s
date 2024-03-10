IO_STATUS = $7f00
IO_DATA = $7f01
DDR_CTRL = $7f02
DDR_DATA = $7f03

RD = %00000001
WR = %00000010
TXE = %10000000
RXE = %01000000

    .org $0000
    .org $8000

start:

reset:
    ldx #$ff
    txs

    lda #%11111111 ; Set all pins on port A to output
    sta DDR_DATA
    lda #%00000011 ; Set lowest 2 pins on port B to output
    sta DDR_CTRL
loop:
    ldx #0
next:
    lda #%00000011 ; set WR and RD to High
    sta IO_STATUS

wait:
    lda IO_STATUS
    sta IO_DATA
    bmi wait

    lda message,x  ; Set PORT A to next char
    beq loop
    sta IO_DATA
    inx

    lda #WR        ; Write (active low)
    sta IO_STATUS
    jmp next

message: .asciiz "Hello, World!",10

    .org $fffc
    .word start
    .word 0
