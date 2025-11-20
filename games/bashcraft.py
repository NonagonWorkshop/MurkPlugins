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
rot_speed = 10  # degrees per press

# ----- Screen -----
W, H = 60, 20  # width x height in characters (will scale 3x3)
BLOCK_SCALE = 3
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

# ----- Draw function with 3x3 blocks -----
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
                shade = int((y / ceiling) * 3)
                char = '"' if shade < 1 else "'" if shade < 2 else '.'
            elif y <= floor:
                pos_in_wall = y - ceiling
                ratio = pos_in_wall / wall_height
                if distance_to_wall < MAX_DEPTH/4:
                    char = '█' if ratio < 0.3 else '▓' if ratio < 0.6 else '▒'
                elif distance_to_wall < MAX_DEPTH/2:
                    char = '▓' if ratio < 0.3 else '▒' if ratio < 0.6 else '░'
                else:
                    char = '░'
            else:
                floor_distance = (y - H/2) / (H/2)
                char = '.' if floor_distance < 0.3 else ',' if floor_distance < 0.6 else '`'

            # Repeat horizontally for 3x3 block effect
            line += char * BLOCK_SCALE
        # Repeat vertically for 3x3 block effect
        for _ in range(BLOCK_SCALE):
            print(line)

# ----- Movement -----
def move(forward=True):
    global px, py
    angle = math.radians(pa)
    dx = math.cos(angle) * speed
    dy = math.sin(angle) * speed
    if not forward:
        dx, dy = -dx, -dy
    nx, ny = px + dx, py + dy
    if get_map(nx, ny) != '#':
        px, py = nx, ny

# ----- Main loop -----
while True:
    draw()
    key = getch().lower()
    if key == 'w':
        move(True)
    elif key == 's':
        move(False)
    elif key == 'a':
        pa = (pa - rot_speed) % 360
    elif key == 'd':
        pa = (pa + rot_speed) % 360
    elif key == 'q':
        break
