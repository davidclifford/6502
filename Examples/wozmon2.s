  .org $1000

KEYPRESS = $82                      ; Last key pressed
XAML  = $84                         ; Last "opened" location Low
XAMH  = $85                         ; Last "opened" location High
STL   = $86                         ; Store address Low
STH   = $87                         ; Store address High
L     = $88                         ; Hex value parsing Low
H     = $89                         ; Hex value parsing High
YSAV  = $8A                         ; Used to see if hex value is given
MODE  = $8B                         ; $00=XAM, $7F=STOR, $AE=BLOCK XAM

IN    = $0200                       ; Input buffer

IO_DATA   = $C000
IO_STATUS = $C001
IO_DDR_DATA  = $C002
IO_DDR_CTRL  = $C003
IO_RD        = %00000001
IO_WR        = %00000010

START:
                CLD
                LDX     #$FF
                TXS

RESET:
                LDA     #$FF                    ;
                STA IO_DDR_DATA                 ; UART All output (default)
                LDA     #$03                    ;
                STA IO_DDR_CTRL                 ; UART Ctrl pins [OI....RW] B1=Read B0=Write as output, UART Status B7=out B6=input as input
                LDA     #$1B                    ; Begin with escape.

NOTCR:
                CMP     #$08                    ; Backspace key?
                BEQ     BACKSPACE               ; Yes.
                CMP     #$1B                    ; ESC?
                BEQ     ESCAPE                  ; Yes.
                INY                             ; Advance text index.
                BPL     NEXTCHAR                ; Auto ESC if line longer than 127.

ESCAPE:
                LDA     #'/'                    ; "/".
                JSR     ECHO                    ; Output it.

GETLINE:
                LDA     #$0A                    ; Send CR
                JSR     ECHO

                LDY     #$01                    ; Initialize text index.
BACKSPACE:
                LDA     #' '
                JSR     ECHO
                LDA     #$08
                JSR     ECHO
                DEY                             ; Back up text index.
                BMI     GETLINE                 ; Beyond start of line, reinitialize.

NEXTCHAR:
                JSR     INPUTKEY                ; Get Keypress
                STA     IN,Y                    ; Add to text buffer.
                JSR     ECHO                    ; Display character.
                CMP     #$0A                    ; CR?
                BNE     NOTCR                   ; No.

                LDY     #$FF                    ; Reset text index.
                LDA     #$00                    ; For XAM mode.
                TAX                             ; X=0.
SETBLOCK:
                ASL
SETSTOR:
                ASL                             ; Leaves $7B if setting STOR mode.
                STA     MODE                    ; $00 = XAM, $74 = STOR, $B8 = BLOK XAM.
BLSKIP:
                INY                             ; Advance text index.
NEXTITEM:
                LDA     IN,Y                    ; Get character.
                CMP     #$0A                    ; CR?
                BEQ     GETLINE                 ; Yes, done this line.
                CMP     #$2E                    ; "."?
                BCC     BLSKIP                  ; Skip delimiter.
                BEQ     SETBLOCK                ; Set BLOCK XAM mode.
                CMP     #$3A                    ; ":"?
                BEQ     SETSTOR                 ; Yes, set STOR mode.
                CMP     #$52                    ; "R"?
                BEQ     RUN                     ; Yes, run user program.
                STX     L                       ; $00 -> L.
                STX     H                       ;    and H.
                STY     YSAV                    ; Save Y for comparison

NEXTHEX:
                LDA     IN,Y                    ; Get character for hex test.
                EOR     #$30                    ; Map digits to $0-9.
                CMP     #$0A                    ; Digit?
                BCC     DIG                     ; Yes.
                ADC     #$88                    ; Map letter "A"-"F" to $FA-FF.
                CMP     #$FA                    ; Hex letter?
                BCC     NOTHEX                  ; No, character not hex.
DIG:
                ASL
                ASL                             ; Hex digit to MSD of A.
                ASL
                ASL

                LDX     #$04                    ; Shift count.
HEXSHIFT:
                ASL                             ; Hex digit left, MSB to carry.
                ROL     L                       ; Rotate into LSD.
                ROL     H                       ; Rotate into MSD's.
                DEX                             ; Done 4 shifts?
                BNE     HEXSHIFT                ; No, loop.
                INY                             ; Advance text index.
                BNE     NEXTHEX                 ; Always taken. Check next character for hex.

NOTHEX:
                CPY     YSAV                    ; Check if L, H empty (no hex digits).
                BEQ     ESCAPE                  ; Yes, generate ESC sequence.

                BIT     MODE                    ; Test MODE byte.
                BVC     NOTSTOR                 ; B6=0 is STOR, 1 is XAM and BLOCK XAM.

                LDA     L                       ; LSD's of hex data.
                STA     (STL,X)                 ; Store current 'store index'.
                INC     STL                     ; Increment store index.
                BNE     NEXTITEM                ; Get next item (no carry).
                INC     STH                     ; Add carry to 'store index' high order.
TONEXTITEM:     JMP     NEXTITEM                ; Get next command item.

RUN:
                JMP     (XAML)                  ; Run at current XAM index.

NOTSTOR:
                BMI     XAMNEXT                 ; B7 = 0 for XAM, 1 for BLOCK XAM.

                LDX     #$02                    ; Byte count.
SETADR:         LDA     L-1,X                   ; Copy hex data to
                STA     STL-1,X                 ;  'store index'.
                STA     XAML-1,X                ; And to 'XAM index'.
                DEX                             ; Next of 2 bytes.
                BNE     SETADR                  ; Loop unless X = 0.

NXTPRNT:
                BNE     PRDATA                  ; NE means no address to print.
                LDA     #$0A                    ; CR.
                JSR     ECHO                    ; Output it.
                LDA     XAMH                    ; 'Examine index' high-order byte.
                JSR     PRBYTE                  ; Output it in hex format.
                LDA     XAML                    ; Low-order 'examine index' byte.
                JSR     PRBYTE                  ; Output it in hex format.
                LDA     #':'                    ; ":".
                JSR     ECHO                    ; Output it.

PRDATA:
                LDA     #' '                    ; Blank.
                JSR     ECHO                    ; Output it.
                LDA     (XAML,X)                ; Get data byte at 'examine index'.
                JSR     PRBYTE                  ; Output it in hex format.
XAMNEXT:        STX     MODE                    ; 0 -> MODE (XAM mode).
                LDA     XAML
                CMP     L                       ; Compare 'examine index' to hex data.
                LDA     XAMH
                SBC     H
                BCS     TONEXTITEM              ; Not less, so no more data to output.

                INC     XAML
                BNE     MOD8CHK                 ; Increment 'examine index'.
                INC     XAMH

MOD8CHK:
                LDA     XAML                    ; Check low-order 'examine index' byte
                AND     #$07                    ; For MOD 8 = 0
                BPL     NXTPRNT                 ; Always taken.

PRBYTE:
                PHA                    ; Save A for LSD.
                LSR
                LSR
                LSR                    ; MSD to LSD position.
                LSR
                JSR     PRHEX                   ; Output hex digit.
                PLA                    ; Restore A.

PRHEX:
                AND     #$0F                    ; Mask LSD for hex print.
                ORA     #'0'                    ; Add "0".
                CMP     #$3A                    ; Digit?
                BCC     ECHO                    ; Yes, output it.
                ADC     #$06                    ; Add offset for letter.

ECHO:
                BIT     IO_STATUS               ; Wait for output to be ready
                BMI     ECHO
                PHA                             ; Save A.
                LDA     #(IO_WR|IO_RD)          ; Set WR and RD to High
                STA     IO_STATUS
                PLA
                STA     IO_DATA                 ; Output Character to UART
                PHA
                LDA     #IO_WR                  ; Write (active low)
                STA     IO_STATUS
                LDA     #(IO_WR|IO_RD)          ; Set WR and RD to High
                STA     IO_STATUS
                PLA                             ; Restore A.
                RTS                             ; Return.

INPUTKEY:
                BIT     IO_STATUS               ; Wait for keypress
                BVS     INPUTKEY

                LDA     #$00                    ; SET ALL PINS ON PORT A TO INPUT
                STA IO_DDR_DATA
                LDA     #IO_RD                  ; READ PIN FOR UART (ACTIVE LOW)
                STA     IO_STATUS
                LDA     IO_DATA                 ; READ DATA (KEYPRESS)
                STA     KEYPRESS                ; SAVE DATA
                LDA     #(IO_WR|IO_RD)          ; SET WR AND RD TO HIGH
                STA     IO_STATUS
                LDA     #$FF                    ; SET ALL PINS ON PORT A TO OUTPUT
                STA IO_DDR_DATA
                LDA     KEYPRESS                ; RESTORE KEYPESS
                RTS

                .org    $FFFA                       ; ---VECTORS---
                .word   $0F00                       ; NMI vector
                .word   START                       ; RESET vector
                .word   $0000                       ; IRQ vector
