        .org $1000

; ---------------------------------------------------------
; DRAW_LINE_16 — Bresenham line drawing with 16-bit X
; Inputs:
;   X0lo/X0hi, Y0
;   X1lo/X1hi, Y1
; ---------------------------------------------------------

DRAW_LINE_16:
        ; curX = X0
        LDA X0lo
        STA curXlo
        LDA X0hi
        STA curXhi

        ; curY = Y0
        LDA Y0
        STA curY

; ---------------------------------------------------------
; dx = abs(X1 - X0)
; ---------------------------------------------------------

        ; dx = X1 - X0
        LDA X1lo
        SEC
        SBC X0lo
        STA dxlo
        LDA X1hi
        SBC X0hi
        STA dxhi

        ; if negative, dx = -dx
        BPL dx_ok
        ; two's complement
        LDA dxlo
        EOR #$FF
        ADC #1
        STA dxlo
        LDA dxhi
        EOR #$FF
        ADC #0
        STA dxhi
dx_ok:

; ---------------------------------------------------------
; dy = abs(Y1 - Y0)  (still 8-bit)
; ---------------------------------------------------------

        LDA Y1
        SEC
        SBC Y0
        BPL dy_ok
        EOR #$FF
        ADC #1
dy_ok:
        STA dy

; ---------------------------------------------------------
; sx = +1 or -1
; ---------------------------------------------------------

        LDA X1hi
        CMP X0hi
        BNE sx_hi_cmp
        LDA X1lo
        CMP X0lo
sx_hi_cmp:
        BPL sx_pos
        LDA #$FF
        BRA sx_done
sx_pos:
        LDA #1
sx_done:
        STA sx

; ---------------------------------------------------------
; sy = +1 or -1
; ---------------------------------------------------------

        LDA Y1
        CMP Y0
        BPL sy_pos
        LDA #$FF
        BRA sy_done
sy_pos:
        LDA #1
sy_done:
        STA sy

; ---------------------------------------------------------
; err = dx - dy
; ---------------------------------------------------------

        ; err = dx - dy
        LDA dxlo
        SEC
        SBC dy
        STA errlo
        LDA dxhi
        SBC #0
        STA errhi

; ---------------------------------------------------------
; Main loop
; ---------------------------------------------------------

line_loop:
        ; Plot pixel at (curX, curY)
        SEC
        JSR PLOT_PIXEL_16

        ; Check if done
        LDA curXlo
        CMP X1lo
        BNE not_done
        LDA curXhi
        CMP X1hi
        BNE not_done
        LDA curY
        CMP Y1
        BEQ line_done
not_done:

; ---------------------------------------------------------
; e2 = err * 2
; ---------------------------------------------------------

        LDA errlo
        ASL A
        STA e2lo
        LDA errhi
        ROL A
        STA e2hi

; ---------------------------------------------------------
; if e2 > -dy: err -= dy, x += sx
; ---------------------------------------------------------

        ; Compare e2 with -dy (8-bit dy)
        LDA e2lo
        CLC
        ADC dy
        LDA e2hi
        ADC #0
        BMI skip_x

        ; err -= dy
        LDA errlo
        SEC
        SBC dy
        STA errlo
        LDA errhi
        SBC #0
        STA errhi

        ; curX += sx (16-bit)
        LDA curXlo
        CLC
        ADC sx
        STA curXlo
        LDA curXhi
        ADC #0
        STA curXhi

skip_x:

; ---------------------------------------------------------
; if e2 < dx: err += dx, y += sy
; ---------------------------------------------------------

        ; Compare e2 with dx
        LDA e2lo
        SEC
        SBC dxlo
        LDA e2hi
        SBC dxhi
        BPL skip_y

        ; err += dx
        LDA errlo
        CLC
        ADC dxlo
        STA errlo
        LDA errhi
        ADC dxhi
        STA errhi

        ; curY += sy
        LDA curY
        CLC
        ADC sy
        STA curY

skip_y:
        BRA line_loop

line_done:
        RTS

; ---------------------------------------------------------
; PLOT_PIXEL_16
; Inputs:
;   curXlo / curXhi = X coordinate (0–399)
;   curY            = Y coordinate
;   C = 1 to set pixel, 0 to clear pixel
;
; Bitmap:
;   Base address = $830D
;   Bytes per line = 64
;   Visible bytes  = 50
;   8 pixels per byte, MSB = leftmost
; ---------------------------------------------------------

PLOT_PIXEL_16:

; ---------------------------------------------------------
; Compute byte offset = (Y * 64) + (X >> 3)
; ---------------------------------------------------------

        ; Y * 64 = Y << 6
        LDA curY
        ASL A        ; *2
        ASL A        ; *4
        ASL A        ; *8
        ASL A        ; *16
        ASL A        ; *32
        ASL A        ; *64
        STA addrLo
        LDA #0
        ADC #0       ; propagate carry
        STA addrHi

        ; Add (X >> 3)
        LDA curXlo
        LSR A
        LSR A
        LSR A        ; X >> 3 (low byte)
        CLC
        ADC addrLo
        STA addrLo
        BCC no_xhi
        INC addrHi
no_xhi:

        ; Add high bits of X >> 3
        LDA curXhi
        LSR A
        LSR A
        LSR A        ; high part of X >> 3
        CLC
        ADC addrHi
        STA addrHi

; ---------------------------------------------------------
; Add base address $830D
; ---------------------------------------------------------

        CLC
        LDA addrLo
        ADC #<$830D
        STA addrLo
        LDA addrHi
        ADC #>$830D
        STA addrHi

; ---------------------------------------------------------
; Compute bit mask = 1 << (7 - (X & 7))
; ---------------------------------------------------------

        LDA curXlo
        AND #7        ; low 3 bits
;        EOR #7        ; reverse bit order
        TAX           ; shift count

        LDA #$80      ; MSB
mask_shift:
        CPX #0
        BEQ mask_ready
        LSR A
        DEX
        BRA mask_shift
mask_ready:
        STA mask

; ---------------------------------------------------------
; Read-modify-write pixel
; ---------------------------------------------------------

        LDY #0
        LDA (addrLo),Y

;        BCC clear_pixel

set_pixel:
        ORA mask
        BRA write_back

clear_pixel:
        ; Clear bit using AND with inverted mask
        EOR mask
        AND mask
        EOR mask

write_back:
        STA (addrLo),Y
        RTS


; ---------------------------------------------------------
; Zero-page workspace
; ---------------------------------------------------------

        .org $A0
; ---------------------------------------------------------
; Zero-page variables
; ---------------------------------------------------------
X0lo:   ds 1 ; A0
X0hi:   ds 1
Y0:     ds 1 ; A2
X1lo:   ds 1 ; A3
X1hi:   ds 1
Y1:     ds 1 ; A5

curXlo: ds 1
curXhi: ds 1
curY:   ds 1

dxlo:   ds 1
dxhi:   ds 1
dy:     ds 1

sx:     ds 1
sy:     ds 1

errlo:  ds 1
errhi:  ds 1
e2lo:   ds 1
e2hi:   ds 1

addrLo: ds 1
addrHi: ds 1
mask:   ds 1
