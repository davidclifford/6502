; The source code for the 6502 test follows.
    .org $00
tmp1:   db
tmp2:   db
number: dw
index:  dw

    .org $1000
direxe:
    lda #10
    jsr IO_ECHO
    ldy #0 ; Mark all numbers as primes to begin
    lda #$ff
l1:
    sta array,y
    iny
    bne l1
    sty number+1 ; start with number=2
    lda #2
    sta number
mbuc: lda number ; check if prime
    sta tmp1
    lda number+1
    sta tmp2
    lsr tmp2 ; y = number/8
    ror tmp1
    lsr tmp2
    ror tmp1
    lsr tmp2
    ror tmp1
    ldy tmp1
    lda number ; A = 1<<(number&7)
    and #7
    tax
    lda #1
    cpx #0
    beq l3
l2: asl
    dex
    bne l2
l3: and array,y ; check bit
    bne l35 ; not prime
    jmp nxn
    ; number is prime. print it
l35: lda number
    sta tmp1
    lda number+1
    sta tmp2
    ; tmp1-tmp2: data to be printed
    ldy #0
prn1: ;------------- divide tmp1-tmp2 by 10. Remainder result in A
    ldx #16
    lda #0
dv1: asl tmp1
    rol tmp2
    rol
    cmp #10
    bcc dv2
    sbc #10
    inc tmp1
dv2: dex
    bne dv1
    ;-------------
    clc
    adc #'0'
    pha
    iny
    lda tmp1
    ora tmp2
    bne prn1
    ;-------------
prn2: pla
    jsr IO_ECHO
    dey
    bne prn2
    lda #' '
    jsr IO_ECHO
    ;--------------- Now, mark every multiple of number as not prime
    lda number ; index=number
    sta index
    lda number+1
    sta index+1
buc2: clc ; index+=number
    lda index
    adc number
    sta index
    sta tmp1
    lda index+1
    adc number+1
    sta index+1
    sta tmp2
    lda #7 ; if (index>=$800) break
    cmp index+1
    bcc nxn
    lsr tmp2 ; y = index/8
    ror tmp1
    lsr tmp2
    ror tmp1
    lsr tmp2
    ror tmp1
    ldy tmp1
    lda index ; A = ~(1<<(number&7))
    and #7
    tax
    lda #1
    cpx #0
    beq l7
l6: asl
    dex
    bne l6
l7: eor #$ff
    and array,y ; mark the bit
    sta array,y
    jmp buc2
nxn: inc number ; number++
    bne l5
    inc number+1
l5: lda number+1 ; if (number&0x7ff)!=0 continue
    cmp #8
    beq theend
    jmp mbuc
theend: rts

array=$300 ; 256 byte array

    .include io.s
