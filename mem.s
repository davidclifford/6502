IO_STATUS = $A001
IO_DATA = $A000
MEM = $1000

    .org $C000
start:
    ldx #$ff                        ; Init stack
    txs
    stz MEM                         ; Zero MEM

loop:
    bit IO_STATUS                   ;  wait for key press
    bvs loop                        ;

    lda IO_DATA                     ; get key press
    sta MEM                         ; store in RAM

    lda #'*'
    sta IO_DATA

    lda MEM                         ; load from RAM
    sta IO_DATA                     ; output (echo) keypress

    jmp loop                        ; try again

    .org $fffc
    .word start
    .word 0
