import json#
# VGA PIC converter
#

from numpy import uint8
from PIL import Image
import sys
import pygame
from pygame import gfxdraw

filename = 'finch-dither-mono'


def plot(x, y, v):
    psize = 4
    col = (255*v, 255*v, 255*v)
    for yy in range(psize):
        for xx in range(psize):
            gfxdraw.pixel(screen, x*psize+xx, y*psize+yy, col)


pygame.init()
screen = pygame.display.set_mode((1600, 960))

image = Image.open(filename+'.png')
pixels = image.load()

hex_file = open(filename+'.hex', 'w')

for y in range(240):
    line = f'{y * 64 + 0x830D:04X}: '
    for x0 in range(50):
        v = 0
        for x1 in range(8):
            x = x1 + x0*8
            pix = pixels[x, y]
            p = int(pix > 0)
            v = (v << 1) + int(pix > 0)
            plot(x, y, p)
        line += f'{v:02X} '

        if x0 % 8 == 7:
            print(f'\n{line}')
            hex_file.write(f'\n{line}')
            addr = x0 + y * 64 + 0x830D
            line = f'{addr:04X}: '

    print(f'\n{line}')
    hex_file.write(f'\n{line}')
    addr = x0 + y * 64 + 0x830D
    line = f'{addr:04X}: '

    pygame.display.update()

hex_file.close()

while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
