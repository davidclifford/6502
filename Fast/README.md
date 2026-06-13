# FAST 65C02

My implementation of George Foot's FAST 6502 project

## Differences
* Memory map
  * $0000 - $7FFF: RAM (Clocked at 32MHz)
  * $8000 - $BFFF: Banked area
  * $C000 - $FEFF: ROM (Monitor at $F000)
  * $FF00 - $FFBF: Peripherals (16 bytes each)
  * $FFFA - $FFFF: Vectors
* 16k banked area $8000 - $BFFF, for VGA and other uses (SD Card, SSD with 39SF040) 
* Using 68B50 for I/O. May try 6551 and/or U245R (with 6522?)
* Small monitor in ROM at $F000
* Peripherals:
  * Bank pointer 
  * SD CARD
  * I/O: 65B50, 6551 or U245R
  * 16x16=>32 Hardware Multiplier (unsigned)
  * 8x8 ALU ROM (mult, div, mod, div10, mod10, square etc)
  * Sound
  * Keyboard (PS2 or Matrix)

