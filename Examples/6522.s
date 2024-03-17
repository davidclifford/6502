IO_DATA = $c000
IO_STATUS = $c001
DDR_DATA = $c002
DDR_CTRL = $c003

RD = %00000001
WR = %00000010
TXE = %10000000
RXE = %01000000

    .org $c000
    .org $c100

start:
    cld
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
;    sta IO_DATA
    bmi wait

    lda message,x  ; Set PORT A to next char
    beq loop
    sta IO_DATA
    inx

    lda #WR        ; Write (active low)
    sta IO_STATUS
    jmp next

message: .asciiz "The quick brown fox jumps over the lazy dog!",10

    .org $fffc
    .word start
    .word 0
