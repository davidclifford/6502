# David Clifford 07/02/2026
#
# Create 2 32 bit hex files
# n^2/4  - N squared divided by 4
# -n^2/4 - N squared divided by 4 but negated
#
# Using the identity:
# A*B = F(A+B) - F(A-B) where F() = (N*N)/4
#
n24_rom_file = open('n24.hex', 'w')
_n24_rom_file = open('-n24.hex', 'w')

n24_rom_file.write('v2.0 raw')
_n24_rom_file.write('v2.0 raw')
for n in range(2 ** 17):
    if n % 8 == 0:
        n24_rom_file.write('\n')
        _n24_rom_file.write('\n')

    product = int((n * n) / 4)
    n24_rom_file.write(f"{product:08X}"[:8]+" ")

    nn = n - 0x10000
    neg = int((nn * nn) / 4)
    neg = neg ^ 0xFFFFFFFF
    _n24_rom_file.write(f"{neg:08X}"[:8]+" ")

n24_rom_file.close()
_n24_rom_file.close()
