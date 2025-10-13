import pygame
import random
import time
pygame.init()

screen = pygame.display.set_mode((1920, 1080))
pygame.display.set_caption("Hello World")
pygame.display.toggle_fullscreen()

co_ords = []
for pix in range(0, 108):
    x = random.randint(0, 255)
    y = random.randint(0, 255)
    co_ords.append([x, y])

while True:
    screen.fill(0)
    i = 0
    for c in co_ords:
        pygame.draw.line(screen, (c[0], c[1], 0), (0, i), (1920, i))
        i += 1
    pygame.display.flip()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
