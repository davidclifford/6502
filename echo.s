IO_STATUS = $A001
IO_DATA = $A000

    .org $C000
start:
    ldx #$ff
    txs

loop:
    bit IO_STATUS                   ;  wait for key press
    bvs loop                        ;
    lda IO_DATA                     ; get key press

loop2:
    bit IO_STATUS
    bmi loop2
    sta IO_DATA                     ; output (echo) keypress

    jmp loop                        ; try again

    .org $fffc
    .word start
    .word 0
