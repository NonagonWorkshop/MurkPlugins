#!/usr/bin/env python3
import math, sys, tty, termios, os

# ----- Map -----
MAP = [
    "########",
    "#......#",
    "#..##..#",
    "#......#",
    "#......#",
    "########"
]

MAP_W = len(MAP[0])
MAP_H = len(MAP)

# ----- Player -----
px, py = 3.5, 3.5
pa = 0.0
speed = 0.2

# ----- Screen -----
W, H = 60, 25  # bigger display
FOV = 60
MAX_DEPTH = 10

# ----- Input -----
def getch():
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
    return ch

# ----- Map helpers -----
def get_map(x, y):
    x = int(x)
    y = int(y)
    if 0 <= x < MAP_W and 0 <= y < MAP_H:
        return MAP[y][x]
    return '#'

# ----- Draw function with shading -----
def draw():
    os.system('clear')
    for y in range(H):
        line = ""
        for x in range(W):
            ray_angle = math.radians(pa - FOV/2 + x*FOV/W)
            distance_to_wall = 0.0
            hit = False
            while not hit and distance_to_wall < MAX_DEPTH:
                distance_to_wall += 0.05
                test_x = px + distance_to_wall * math.cos(ray_angle)
                test_y = py + distance_to_wall * math.sin(ray_angle)
                if get_map(test_x, test_y) == '#':
                    hit = True
            if distance_to_wall == 0:
                distance_to_wall = 0.01

            wall_height = int(H / distance_to_wall)
            ceiling = H//2 - wall_height//2
            floor = H//2 + wall_height//2

            if y < ceiling:
                # ceiling shading (farther is lighter)
                shade = int((y / ceiling) * 3)
                line += '"' if shade < 1 else "'" if shade < 2 else '.'
            elif y <= floor:
                # wall shading (top = lighter, bottom = darker)
                pos_in_wall = y - ceiling
                wall_section = wall_height
                ratio = pos_in_wall / wall_section
                if distance_to_wall < MAX_DEPTH/4:
                    if ratio < 0.3:
                        line += '█'
                    elif ratio < 0.6:
                        line += '▓'
                    else:
                        line += '▒'
                elif distance_to_wall < MAX_DEPTH/2:
                    if ratio < 0.3:
                        line += '▓'
                    elif ratio < 0.6:
                        line += '▒'
                    else:
                        line += '░'
                else:
                    line += '░'
            else:
                # floor shading (farther = darker)
                floor_distance = (y - H/2) / (H/2)
                if floor_distance < 0.3:
                    line += '.'
                elif floor_distance < 0.6:
                    line += ','
                else:
                    line += '`'
        print(line)

# ----- Movement -----
def move(dx, dy):
    global px, py
    nx, ny = px + dx, py + dy
    if get_map(nx, ny) != '#':
        px, py = nx, ny

# ----- Main loop -----
while True:
    draw()
    key = getch().lower()
    if key == 'w':
        move(math.cos(math.radians(pa))*speed, math.sin(math.radians(pa))*speed)
    elif key == 's':
        move(-math.cos(math.radians(pa))*speed, -math.sin(math.radians(pa))*speed)
    elif key == 'a':
        pa = (pa - 10) % 360
    elif key == 'd':
        pa = (pa + 10) % 360
    elif key == 'q':
        break
