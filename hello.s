IO_STATUS = $A001
IO_DATA = $A000
START = $C000

    .org START
start:
    ldx #$ff
    txs

; Print a string
print:
    ldx #0
loop:
    bit IO_STATUS                   ; Wait for output is ready
    bmi loop
    lda message,x                   ; Get next char from string
    beq loop1                       ; If \0 goto input
    sta IO_DATA                     ; Output character
    inx
    jmp loop

; Input
loop1:
    bit IO_STATUS                   ;  wait for key press
    bvs loop1                       ;
    lda IO_DATA                     ; get key press

loop2:
    bit IO_STATUS                   ; Wait for output is ready
    bmi loop2
    sta IO_DATA                     ; output (echo) keypress
    cmp 10
    bne loop1                       ; next keypress

    jmp print

message: asciiz "The quick brown fox jumps over the lazy dog!",10

    .org $fffc
    .word START
    .word 0
