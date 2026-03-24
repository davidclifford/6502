; ------------------------------------------------------------
; LINE_DRAW: draw line from (X0,Y0) to (X1,Y1)
; Minimalist version: separate X-major and Y-major loops
; ------------------------------------------------------------
X0      = $00
Y0      = $01
X1      = $02
Y1      = $03
DX      = $04
DY      = $05
SX      = $06
SY      = $07
ERR     = $08

draw_line:
        ; dx = x1 - x0
        LDA X1
        SEC
        SBC X0
        STA DX
        BPL @DX_POS
        LDA #$FF
        STA SX
        LDA DX
        EOR #$FF
        CLC
        ADC #$01
        STA DX
        BRA @DX_DONE
@DX_POS:
        LDA #$01
        STA SX
@DX_DONE:

        ; dy = y1 - y0
        LDA Y1
        SEC
        SBC Y0
        STA DY
        BPL @DY_POS
        LDA #$FF
        STA SY
        LDA DY
        EOR #$FF
        CLC
        ADC #$01
        STA DY
        BRA @DY_DONE
@DY_POS:
        LDA #$01
        STA SY
@DY_DONE:

        ; choose major axis
        LDA DX
        CMP DY
        BCC @Y_MAJOR

; ---------------- X-major loop ----------------
; error = dx/2
        LDA DX
        LSR A
        STA ERR

        LDA DX
        CLC
        ADC #$01
        TAX                 ; loop counter in X

@X_LOOP:
        JSR PLOT

        LDA ERR
        CLC
        ADC DY
        STA ERR
        CMP DX
        BCC @NO_Y_STEP
        SEC
        SBC DX
        STA ERR
        LDA Y0
        CLC
        ADC SY
        STA Y0
@NO_Y_STEP:
        LDA X0
        CLC
        ADC SX
        STA X0

        DEX
        BNE @X_LOOP
        RTS

; ---------------- Y-major loop ----------------
@Y_MAJOR:
        ; error = dy/2
        LDA DY
        LSR A
        STA ERR

        LDA DY
        CLC
        ADC #$01
        TAX                 ; loop counter in X

@Y_LOOP:
        JSR PLOT

        LDA ERR
        CLC
        ADC DX
        STA ERR
        CMP DY
        BCC @NO_X_STEP
        SEC
        SBC DY
        STA ERR
        LDA X0
        CLC
        ADC SX
        STA X0
@NO_X_STEP:
        LDA Y0
        CLC
        ADC SY
        STA Y0

        DEX
        BNE @Y_LOOP
        RTS
