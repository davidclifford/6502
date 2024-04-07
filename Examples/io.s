IO_DATA         = $C000
IO_STATUS       = $C001
IO_DDR_DATA     = $C002
IO_DDR_CTRL     = $C003
IO_RD           = %00000001
IO_WR           = %00000010
IO_KEY          = $82                           ; ZP Last key pressed

IO_INIT:
                LDA     #$FF                    ;
                STA IO_DDR_DATA                 ; UART All output (default)
                LDA     #$03                    ;
                STA IO_DDR_CTRL                 ; UART Ctrl pins [OI....RW] B1=Read B0=Write as output, UART Status B7=out B6=input as input
                RTS

IO_ECHO:
                BIT     IO_STATUS               ; Wait for output to be ready
                BMI     IO_ECHO
IO_OUT:
                STA     IO_DATA                 ; Output Character to UART
                PHA
                LDA     #(IO_WR|IO_RD)          ; Set WR and RD to High
                STA     IO_STATUS
                LDA     #IO_WR                  ; Write (active low)
                STA     IO_STATUS
                LDA     #(IO_WR|IO_RD)          ; Set WR and RD to High
                STA     IO_STATUS
                PLA
                RTS                             ; Return.

IO_INKEY:
                BIT     IO_STATUS               ; Wait for keypress
                BVS     IO_INKEY
IO_IN:
                LDA     #$00                    ; SET ALL PINS ON PORT A TO INPUT
                STA     IO_DDR_DATA
                LDA     #IO_RD                  ; READ PIN FOR UART (ACTIVE LOW)
                STA     IO_STATUS
                LDA     IO_DATA                 ; READ DATA (KEYPRESS)
                STA     IO_KEY                  ; SAVE DATA
                LDA     #(IO_WR|IO_RD)          ; SET WR AND RD TO HIGH
                STA     IO_STATUS
                LDA     #$FF                    ; SET ALL PINS ON PORT A TO OUTPUT
                STA     IO_DDR_DATA
                LDA     IO_KEY                  ; RESTORE KEYPESS
                RTS
