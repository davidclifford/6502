IO_STATUS = $c000
IO_DATA = $c001
IO_DDR_CTRL = $c002
IO_DDR_DATA = $c003

    .org $c000
    .org $c100

start:

reset:
    ldx #$ff
    txs

    lda #%11111111 ; Set all pins on port A to output
    sta IO_DDR_DATA
    lda #%11111111 ; Set all pins on port B to output
    sta IO_DDR_CTRL
loop:
    lda #$aa
    sta IO_STATUS

    lda #$55
    sta IO_DATA

halt:
    jmp halt

    .org $fffc
    .word start
    .word 0
