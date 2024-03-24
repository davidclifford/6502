IO_DATA = $c000
IO_STATUS = $c001
DDR_DATA = $c002
DDR_CTRL = $c003

RD = %00000001
WR = %00000010
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
print_heading:
    ldx #0
    lda os_heading,x
    beq os_input_loop
    jsr CHROUT
    inx
    jmp print_heading
os_input_loop:
    lda #10
    jsr CHROUT
    lda #'>'
    jsr CHROUT
    lda #' '
    jsr CHROUT

os_input:
    jsr INKEY
    jsr CHROUT
choose_command:
    cmp #' '
    beq os_input
    cmp #'A'
    bcc skip_case
    cmp #'['
    bcs skip_case
    ora #$20
skip_case:
    cmp #'x'
    beq os_start
    cmp #'c'
    beq change
    cmp 'd'
    beq dump
    cmp 'r'
    beq run
    jmp os_input_loop
change:
dump:
run:
    jmp os_input_loop

;============================================================

INIT_IO:
    lda #ALL_OUT ; Set all pins on port A to output
    sta DDR_DATA
    lda #STATUS_OUT ; Set lowest 2 pins on port B to output
    sta DDR_CTRL
    rts

WAIT_OUT:
    bit IO_STATUS
    bmi WAIT_OUT
    rts

; Waits if output buffer is full and then prints character in A
CHROUT:
    bit IO_STATUS
    bmi CHROUT
OUTCHAR:
    pha
    sta IO_DATA
    lda #WR        ; Write (active low)
    sta IO_STATUS
    lda #(WR | RD) ; set WR and RD to High
    sta IO_STATUS
    pla
    rts

WAIT_IN:
    bit IO_STATUS
    bvs WAIT_IN
    rts

; Wait for key to be pressed and then
; Returns ascii value of key in A and stores in variable key_press
INKEY:
    bit IO_STATUS
    bvs INKEY
INCHAR:
    lda #ALL_IN; Set all pins on port A to input
    sta DDR_DATA
    lda #RD ; Read (active low)
    sta IO_STATUS
    lda IO_DATA    ; Read data (keypress)
    sta key_press  ; Save data
    lda #(WR | RD) ; set WR and RD to High
    sta IO_STATUS
    lda #ALL_OUT ; Set all pins on port A to output
    sta DDR_DATA
    lda key_press  ; Restore keypess
    rts

os_heading: .string 10,"[2J[HDAVROS V1.00 March 2024",10

;====================================================================
; OS Ram area 7F00

key_press=$7F00

    .org $fffc
    .word start
    .word 0
