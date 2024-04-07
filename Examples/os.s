IO_DATA = $c000
IO_STATUS = $c001
IO_DDR_DATA = $c002
IO_DDR_CTRL = $c003

IO_RD = %00000001
IO_WR = %00000010
ALL_OUT = %11111111
ALL_IN = %00000000
STATUS_OUT = %00000011

    .org $c000
    .org $c100

start:
    cld
    ldx #$ff
    txs
    jsr INIT_IO
os_start:
    ldx #0
print_heading:
    lda os_heading,x
    beq os_input_loop
    jsr CHROUT
    inx
    bra print_heading
os_input_loop:
    lda #'>'                        ; output > prompt
    jsr CHROUT
    lda #' '
    jsr CHROUT
next_input:
    jsr KEYIN                       ; Read key input
    jsr CHROUT                      ; Echo to screen
    sta cmdchar
    cmp #10
    beq os_input_loop
    cmp #13
    beq os_input_loop               ; Loop if CR or LF key

    ldx #0                          ; Set input buffer to zero
os_input:
    jsr KEYIN                       ; Read next keypress
    jsr CHROUT                      ; Echo keypress

    cmp #' '
    beq os_input                    ; skip spaces
    cmp #10
    beq docmd
    cmp #13
    beq docmd                       ; Exit on LF or CR
    sta hexchar,x
    inx
    cpx #4                          ; Ignore rest of line once 4 hex digits input
    beq waitnl
    bra os_input

waitnl:
    jsr KEYIN                       ; Wait for CR of LF to be pressed
    jsr CHROUT
    cmp #10
    beq cvtaddr
    cmp #13
    beq cvtaddr
    bra waitnl

cvtaddr:
    jsr hexcvt

docmd:
    lda #10
    jsr CHROUT
    lda cmdchar

    cmp #'?'
    beq usage
    cmp #'D'
    beq dump
    cmp #'d'
    beq dump
    cmp #'C'
    beq change
    cmp #'c'
    beq change
    cmp #'R'
    beq run
    cmp #'r'
    beq run
    cmp #'X'
    beq exit
    cmp #'x'
    beq exit
    jmp os_input_loop

; eXit - Restart OS
exit:
    jmp os_start

; Usage - print usage text
usage:
    ldx #0
usage_loop:
    lda os_usage, x
    beq usgae_end
    jsr CHROUT
    inx
    bra usage_loop
usgae_end:
    jmp os_input_loop

; Change - change bytes starting from address
change:


    jmp os_input_loop
; Dump - view memory from address
dump:
    ldy #0
dump_loop1:
    lda addr+1
    jsr prhex
    tya
    jsr prhex
    lda #':'
    jsr CHROUT
dump_loop2:
    lda #' '
    jsr CHROUT
    lda (addr),y
    jsr prhex
    iny
    tya
    and #$0F
    bne dump_loop2

    lda #10
    jsr CHROUT
    cpy #0
    bne dump_loop1

    lda addr+1
    inc
    sta addr+1
    jmp os_input_loop

; Run - Run from an address
run:
    jmp (addr)

    ; Print out number as 2 hex digits (uppercase)
    ; input = a
    ; output = terminal
    ; preserves a

prhex:
    pha
    clc
    lsr
    lsr
    lsr
    lsr
    cmp 10
    bcc digit
    ; A-F
    adc #54                         ; carry is set when we get here so use 54 not 55
    bra outhex
digit:
    adc #'0'
outhex:
    jsr CHROUT

    pla
    pha
    and #$0F
    cmp 10
    bcc digit1
    ; A-F
    adc #54
    bra outhex1
digit1:
    adc #'0'
outhex1:
    jsr CHROUT

    pla
    rts

; Convert 4 char hex number to 16-bit little endian address
hexcvt:
; 1st Nibble
    lda hexchar
    clc
    adc #$1F
    bmi adj0                        ; a-f
    adc #$20
    bmi adj0                        ; A-F
    sec
    sbc #$6F                        ; 0-9
    bra nib0
adj0:
    sec
    sbc #$76
nib0:
    asl
    asl
    asl
    asl       ;top nibble (*16)
    sta addr+1

; 2nd Nibble
    lda hexchar+1
    clc
    adc #$1F
    bmi adj1                        ; a-f
    adc #$20
    bmi adj1                        ; A-F
    sec
    sbc #$6F                        ; 0-9
    bra nib1
adj1:
    sec
    sbc #$76
nib1:
    clc
    adc addr+1
    sta addr+1

; 3rd Nibble
    lda hexchar+2
    clc
    adc #$1F
    bmi adj2                        ; a-f
    adc #$20
    bmi adj2                        ; A-F
    sec
    sbc #$6F                        ; 0-9
    bra nib2
adj2:
    sec
    sbc #$76
nib2:
    asl
    asl
    asl
    asl       ;top nibble (*16)
    sta addr

; 4th Nibble
    lda hexchar+3
    clc
    adc #$1F
    bmi adj3                        ; a-f
    adc #$20
    bmi adj3                        ; A-F
    sec
    sbc #$6F                        ; 0-9
    bra nib3
adj3:
    sec
    sbc #$76
nib3:
    clc
    adc addr
    sta addr

    rts

; Convert byte
bytcvt:
    lda hexchar
    clc
    adc #$1F
    bmi adj                         ; a-f
    adc #$20
    bmi adj                         ; A-F
    sbc #$6F                        ; 0-9
    bra nib
adj:
    sbc #$76
nib:
    asl
    asl
    asl
    asl       ;top nibble (*16)
    sta hex

; bottom Nibble
    lda hexchar+1
    clc
    adc #$1F
    bmi adja                        ; a-f
    adc #$20
    bmi adja                        ; A-F
    sbc #$6F                        ; 0-9
    bra niba
adja:
    sbc #$76
niba:
    adc hex
    sta hex

    rts

;============================================================

INIT_IO:
    lda #ALL_OUT                    ; Set all pins on port A to output
    sta IO_DDR_DATA
    lda #STATUS_OUT                 ; Set lowest 2 pins on port B to output
    sta IO_DDR_CTRL
    rts

WAIT_OUT:
    bit IO_STATUS
    bmi WAIT_OUT
    rts

; Waits if output buffer is full and then prints character in A
CHROUT:
    bit IO_STATUS
    bmi CHROUT
OUTCHR:
    pha
    lda #(IO_WR | IO_RD)            ; set WR and RD to High
    sta IO_STATUS
    pla
    sta IO_DATA
    pha
    lda #IO_WR                      ; Write (active low)
    sta IO_STATUS
    lda #(IO_WR | IO_RD)            ; set WR and RD to High
    sta IO_STATUS
    pla
    rts

WAIT_IN:
    bit IO_STATUS
    bvs WAIT_IN
    rts

; Wait for key to be pressed and then
; Returns ascii value of key in A and stores in variable key_press
KEYIN:
    bit IO_STATUS
    bvs KEYIN
INKEY:
    lda #ALL_IN                     ; Set all pins on port A to input
    sta IO_DDR_DATA
    lda #IO_RD                      ; Read (active low)
    sta IO_STATUS
    lda IO_DATA                     ; Read data (keypress)
    sta key_press                   ; Save data
    lda #(IO_WR | IO_RD)            ; set WR and RD to High
    sta IO_STATUS
    lda #ALL_OUT                    ; Set all pins on port A to output
    sta IO_DDR_DATA
    lda key_press                   ; Restore keypess
    rts

os_heading: .asciiz "[2J[HDAVROS V1.00 March 2024",10,10
os_usage:   .asciiz "Usage: D dump, C change, R run, ? help, X exit",10,10

;====================================================================
; Zero Page
addr      = $80                     ; 2 byte 16-bit address

; OS Ram area 7F00

key_press = $7F00
cmdchar   = $7F01                   ; Command to execute
hexchar   = $7F02                   ; 4 bytes to store hex chars e.g. 1FE3
hex       = $7f08                   ; Byte converted from 2 hex digits in hexchar & hexchar+1

    .org $fffc
    .word start
    .word 0
