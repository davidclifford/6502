; --- Zero Page Variables ---
        .org $90
X1:      ds 2
Y1:      ds 1 ; (1 byte)
X2:      ds 2 ; (2 bytes)
Y2:      ds 1 ; (1 byte)
DX:      ds 2 ; (2 bytes)
DY:      ds 2 ; (2 bytes) - 16-bit for subtraction
ERR:     ds 2 ; (2 bytes)
E2:      ds 2 ; (2 bytes)
STEPX:   ds 1 ; (1 byte)  1 or -1
STEPY:   ds 1 ; (1 byte)  1 or -1
SCR_PTR: ds 2 ; (2 bytes)
TEMP_H:  ds 1 ;
XSHFT:   ds 2 ;

x1 = 0
y1 = 0
x2 = 200
y2 = 120

        .org $1000   ; Example start address
start:
        lda #<x1
        sta X1
        lda #>x1
        sta X1+1

        lda #y1
        sta Y1

        lda #<x2
        sta X2
        lda #>x2
        sta X2+1

        lda #y2
        sta Y2

        JSR LINE

;        BRA start
        RTS

LINE:
        ; Calculate DX = abs(X2 - X1)
        sec
        lda X2
        sbc X1
        sta DX
        lda X2+1
        sbc X1+1
        sta DX+1
        bcs .set_sx_pos
        ; Negate DX
        lda #0
        sec
        sbc DX
        sta DX
        lda #0
        sbc DX+1
        sta DX+1
        lda #$ff    ; StepX = -1
        sta STEPX
        bra .calc_dy
.set_sx_pos
        lda #1      ; StepX = 1
        sta STEPX

.calc_dy
        ; Calculate DY = abs(Y2 - Y1)
        sec
        lda Y2
        sbc Y1
        bcs .set_sy_pos
        eor #$ff
        inc a
        sta DY
        lda #$ff    ; StepY = -1
        sta STEPY
        bra .init_err
.set_sy_pos
        sta DY
        lda #1      ; StepY = 1
        sta STEPY

.init_err
        stz DY+1    ; High byte of DY for 16-bit math
        lda DX
        sec
        sbc DY
        sta ERR
        lda DX+1
        sbc DY+1
        sta ERR+1

.loop
        jsr PLOT_PIXEL

        ; Check if X1==X2 and Y1==Y2
        lda X1
        cmp X2
        bne .step_logic
        lda X1+1
        cmp X2+1
        bne .step_logic
        lda Y1
        cmp Y2
        beq .done

.step_logic
        ; E2 = ERR * 2
        lda ERR
        asl a
        sta E2
        lda ERR+1
        rol a
        sta E2+1

        ; if (E2 > -DY) { ERR -= DY; X1 += STEPX; }
        ; -DY comparison is tricky, easier to check E2 + DY > 0
        clc
        lda E2
        adc DY
        lda E2+1
        adc DY+1
        bmi .check_y    ; If result is negative, E2 <= -DY

        ; ERR -= DY
        sec
        lda ERR
        sbc DY
        sta ERR
        lda ERR+1
        sbc DY+1
        sta ERR+1
        ; X1 += STEPX
        clc
        lda X1
        adc STEPX
        sta X1
        lda X1+1
        adc #0
        sta X1+1
        ; Handle StepX negative (if STEPX is $FF, ADC #0 doesn't carry right)
        bit STEPX
        bpl .check_y
        lda X1+1
        sbc #0          ; Manual borrow if StepX was -1
        sta X1+1

.check_y
        ; if (E2 < DX) { ERR += DX; Y1 += STEPY; }
        sec
        lda DX
        sbc E2
        lda DX+1
        sbc E2+1
        bmi .loop       ; If DX < E2, skip Y step

        ; ERR += DX
        clc
        lda ERR
        adc DX
        sta ERR
        lda ERR+1
        adc DX+1
        sta ERR+1
        ; Y1 += STEPY
        clc
        lda Y1
        adc STEPY
        sta Y1
        bra .loop

.done
        rts

PLOT_PIXEL:
        ; 1. Calculate Y * 64 (Stride)
        ; Pointer = Y1
        lda Y1
        sta SCR_PTR
        stz SCR_PTR+1    ; 65C02 Store Zero

        ; Shift Y left 6 times (Y * 64)
        asl SCR_PTR
        rol SCR_PTR+1    ; *2
        asl SCR_PTR
        rol SCR_PTR+1    ; *4
        asl SCR_PTR
        rol SCR_PTR+1    ; *8
        asl SCR_PTR
        rol SCR_PTR+1    ; *16
        asl SCR_PTR
        rol SCR_PTR+1    ; *32
        asl SCR_PTR
        rol SCR_PTR+1    ; *64

        ; 2. Add Base Address $840D
        lda SCR_PTR
        clc
        adc #$0d
        sta SCR_PTR
        lda SCR_PTR+1
        adc #$83
        sta SCR_PTR+1

        ; 3. Add X / 8 (16-bit shift right 3 times)
        ; Load X into (TEMP_H:A) to perform the shift
        lda X1+1
        sta TEMP_H
        lda X1

        ; Shift 1
        lsr TEMP_H       ; High bit 0 -> Carry
        ror a            ; Carry -> Low bit 7
        ; Shift 2
        lsr TEMP_H
        ror a
        ; Shift 3
        lsr TEMP_H
        ror a

        ; 'a' now holds the byte offset, 'TEMP_H' holds the overflow
        clc
        adc SCR_PTR
        sta SCR_PTR
        lda TEMP_H
        adc SCR_PTR+1
        sta SCR_PTR+1

        ; 4. Apply Pixel Mask
        ; Bitmask: 1 << (7 - (X1 & 7))
        lda X1
        and #7
        tax              ; X = 0-7 index
        lda BIT_TABLE,x  ; Use Absolute,X indexing (no space after comma)
        ora (SCR_PTR)    ; 65C02 Indirect ORA (no Y register needed)
        sta (SCR_PTR)
        rts

; Place this at the very end of your source file
BIT_TABLE:
    db $80, $40, $20, $10, $08, $04, $02, $01
