        .org $1000

; ---------------------------------------------------------
; DRAW_LINE — Bresenham line drawing with 16-bit X
; Inputs:
;       x0, y0
;       x1, y1
; ---------------------------------------------------------

draw_line:
        LDA #1
        STA sx
        STA sy
        ; First compute abs X0 - X1
        SEC
        LDA x0
        SBC x1
        STA dx

        LDA x0+1
        SBC x1+1
        STA dx+1

        ; If result is positive (no borrow), we’re done
        BPL y_diff

        ; Otherwise result is negative → take two’s complement
        ; ABS = -(result)
        LDA dx
        EOR #$FF
        CLC
        ADC #1
        STA dx

        LDA dx+1
        EOR #$FF
        ADC #0
        STA dx+1
        LDA #$FF
        STA sx
y_diff:
        ; Compute abs Y0 - Y1
        SEC
        LDA y0
        SBC y1
        STA dy

        ; If result is positive (no borrow), we’re done
        BPL init_steps

        ; Otherwise result is negative → take two’s complement
        ; ABS = -(result)
        LDA dy
        EOR #$FF
        CLC
        ADC #1
        STA dy
        LDA #$FF
        STA sy
init_steps:
        LDA dx+1
        CMP #0
        BNE x_step
        LDA dx
        CMP dy
        BPL x_step
y_step:
        LDA dx
        STA err
        LDA dx+1
        STA err+1
        LDA dy
        STA h
        STZ h+1
        LDA sx
        STA tx
        STZ ty
        bra iter
x_step:
        LDA dy
        STA err
        STZ err+1
        LDA dx
        STA h
        LDA dx+1
        STA h+1

        LDA sy
        STA ty
        STZ tx
iter:
        LSR h+1
        ROR h
        RTS

; ---------------------------------------------------------
; Zero-page variables
; ---------------------------------------------------------
        .org $A0
x0:     ds 2 ; A0
y0:     ds 1 ; A2
x1:     ds 2 ; A3
y1:     ds 1 ; A5

dx:     ds 2 ; A6
dy:     ds 1 ; A8
sx:     ds 1 ; A9
sy:     ds 1 ; AA

h:      ds 2 ; AB
err:    ds 2 ; AD
tx:     ds 1 ; AF
ty:     ds 1 ; B0
