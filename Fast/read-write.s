    .org $1000
start:
    lda #$80
    sta $830d
    lda #$40
    sta $834d
    lda #$20
    sta $838d
    lda #$10
    sta $83cd
    lda #$08
    sta $840d
    lda #$04
    sta $844d
    lda #$02
    sta $848d
    lda #$01
    sta $84cd

    lda $830d
    ora #$01
    sta $830d

    lda $834d
    ora #$02
    sta $834d

    lda $838d
    ora #$04
    sta $838d

    lda $83cd
    ora #$08
    sta $83cd


    lda $840d
    ora #$10
    sta $840d

    lda $844d
    ora #$20
    sta $844d

    lda $848d
    ora #$40
    sta $848d

    lda $84cd
    ora #$80
    sta $84cd

    rts
