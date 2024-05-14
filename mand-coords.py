def fp_conv(fp):
    return int(fp*256-0.5) & 0xFFFF


print('X CO-ORDS')
for i in range(0, 32):
    print(f'${fp_conv(i*3.5/32-2.5):04x}', end=',')
print()
print('Y CO-ORDS')
for i in range(0, 22):
    print(f'${fp_conv(i*2/22-1):04x}', end=',')
print()

