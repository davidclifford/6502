    .org $C000

OUT = $A000
STAT = $A001

start:
    lda #'H'
    sta OUT
    lda #'e'
    sta OUT
    lda #'l'
    sta OUT
    lda #'l'
    sta OUT
    lda #'o'
    sta OUT
    lda #10
    sta OUT

    ldx #0
loop:
    bit STAT
    
    bmi loop
    lda message,x
    beq start
    sta OUT
    inx
    jmp loop

message: asciiz "The quick brown fox jumps over the lazy dog!",10

    .org $fffc
    .word start
    .word 0
