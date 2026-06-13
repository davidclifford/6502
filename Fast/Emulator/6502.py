from py65.devices import mpu65c02
import time
import sys
import pygame
from pygame import gfxdraw
import pygame.freetype

PIX_SIZE = 3

class MPU(mpu65c02.MPU):
    def __init__(self, *args, **kwargs):
        mpu65c02.MPU.__init__(self, *args, **kwargs)
        self.name = '65C02a'
        self.waiting = False
        self.key_queue = []
        self.screen_change = False

    def opSTA(self, x):
        address = x()
        if address == 0xFF71:
            # print('out', self.a)
            print(chr(self.a), end='')
        else:
            self.memory[address] = self.a
            if 0x8000 <= address < 0xc000:
                self.screen_change = address

    def opLDA(self, x):
        address = x()
        if address == 0xff71:
            ky = 0
            if len(self.key_queue) > 0:
                ky = self.key_queue.pop(0)
            # print('key', ky)
            self.a = ky
        else:
            if address == 0xff70:
                if len(self.key_queue) == 0:
                    self.memory[address] &= 0xfe
                else:
                    self.memory[address] |= 1
            self.a = self.ByteAt(x())
            self.FlagsNZ(self.a)

    def add_key_queue(self, ky):
        self.key_queue.append(ky)

    def get_bitmap(self):
        change = self.screen_change
        self.screen_change = None
        return change


pygame.init()
screen = pygame.display.set_mode((400*PIX_SIZE, 240*PIX_SIZE))
GAME_FONT = pygame.freetype.SysFont("Courier", 16)
pygame.scrap.init()

# Read in ROM from binary file
filename = '../../bin/wozmon_6850.bin'
with open(filename, 'rb') as f:
    rom = bytearray(f.read())

mem = 0x10000 * [0x00]

# Transfer ROM contents to memory
addr = 0x8000
for a in rom:
    mem[addr] = int(a)
    # print(hex(addr), hex(a))
    addr += 1

cpu = MPU(memory=mem, pc=None)

t = time.time()
screen_update = True
while True:
    # time.sleep(0.1)
    cpu.step()
    # status = hex(cpu.ProgramCounter()) + ' ' + hex(cpu.ByteAt(cpu.ProgramCounter())) \
    #                                                + ' ' + hex(cpu.ByteAt(0xff70)) + ' ' + hex(cpu.ByteAt(0xff71)) + ' '
    # GAME_FONT.render_to(screen, (0, 0), status, (255, 255, 255), (0, 0, 0))

    # Init
    if cpu.ByteAt(0xff70) == 0x96:
        cpu.memory[0xff70] = 2

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        if event.type == pygame.KEYDOWN:
            # Handle Pasting (Ctrl+V)
            if event.key == pygame.K_r and (pygame.key.get_mods() & pygame.KMOD_CTRL):
                cpu.reset()
            elif event.key == pygame.K_v and (pygame.key.get_mods() & pygame.KMOD_CTRL):
                pasted = pygame.scrap.get(pygame.SCRAP_TEXT)
                if pasted:
                    # Depending on platform/system, decode may be needed
                    for b in pasted:
                        cpu.add_key_queue(b)
            else:
                key = ord(event.unicode) if event.unicode else 0
                if key > 0:
                    # Convert ENTER to char 10
                    key = 10 if key == 13 else key
                    cpu.memory[0xff70] |= 1
                    cpu.add_key_queue(key)

    screen_address = cpu.get_bitmap()
    if screen_address:
        screen_update = True
        xx = ((screen_address - 0x830d) % 64) * PIX_SIZE
        yy = int((screen_address - 0x830d) / 64) * PIX_SIZE
        aa = cpu.ByteAt(screen_address)
        # print('x,y,a', xx, yy, aa)
        for p in range(8):
            aa = (aa << 1) & 0x1ff
            for px in range(PIX_SIZE):
                for py in range(PIX_SIZE):
                    if aa > 255:
                        screen.set_at((xx*8+p*PIX_SIZE+px, yy+py), (255, 255, 255))
                    else:
                        screen.set_at((xx*8+p*PIX_SIZE+px, yy+py), (0, 0, 0))

    if screen_update:
        if time.time() - t > 0.1:
            pygame.display.flip()
            t = time.time()
            screen_update = False
