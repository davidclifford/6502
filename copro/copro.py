# David Clifford 26/04/2024
#
# Create an COPRO using the following operations
#
# A = LHS (8-BITS)
# B = RHS (8-BITS)
#
# OP = 3-BITS
# ----------------
# 8+8+3 = 19 BITS
#
# Ops
# -----
# 00 A*B lo
# 01 A*B hi
# 02 A%B
# 03 A/B
# 04 AB^2 byte 0
# 05 AB^2 byte 1
# 06 AB^2 byte 2
# 07 AB^2 byte 3

from numpy import uint8, uint16

OPS = ['A*Blo', 'A*Bhi', 'A%B', 'A/B', 'AB^2 0','AB^2 1','AB^2 2','AB^2 3']
copro_rom_file = open('copro.bin', 'wb')

for op in range(8):
    for a in range(256):
        for b in range(256):
            c = (a << 8) + b
            if op == 0:
                d = (a*b) & 0xFF
            if op == 1:
                d = ((a*b) >> 8) & 0xFF
            if op == 2:
                d = 0xFF
                if b > 0:
                    d = (a % b) & 0xFF
            if op == 3:
                d = 0xFF
                if b > 0:
                    d = (a//b) & 0xFF
            if op == 4:
                d = (c*c) & 0xFF
            if op == 5:
                d = ((c*c) >> 8) & 0xFF
            if op == 6:
                d = ((c*c) >> 16) & 0xFF
            if op == 7:
                d = ((c*c) >> 24) & 0xFF
            # Write to rom
            print(f'{OPS[op]}, A: {a}, B: {b} = {d}')
            copro_rom_file.write(uint8(d))

copro_rom_file.close()
