    .org $0000
    .org $8000
start:
    ldx #0
next:
    lda hello,x
    beq start
    sta $7f00
    inx
    jmp next

hello: .asciiz "Hello, World!",10

    .org $fffc
    .word start
    .word 0
