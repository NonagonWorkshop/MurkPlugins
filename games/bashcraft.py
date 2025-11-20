#!/usr/bin/env python3
import math, sys, tty, termios, os
import random

# ----- Map generation from 16-char seed -----
def generate_map(seed=None):
    if seed is None:
        # generate random 16-character seed
        chars = "0123456789ABCDEF"
        seed = "".join(random.choice(chars) for _ in range(16))
        print("Random seed:", seed)
    elif len(seed) != 16:
        raise ValueError("Seed must be exactly 16 characters.")
    
    random.seed(seed)  # set RNG based on seed
    MAP = []
    for y in range(6):
        row = ""
        for x in range(8):
            if y==0 or y==5 or x==0 or x==7:
                row += "#"  # border
            else:
                row += "#" if random.random() < 0.3 else "."  # ~30% walls
        MAP.append(row)
    return MAP

# ----- Ask for seed or generate randomly -----
seed_input = input("Enter 16-character seed (or leave blank for random): ").strip()
if seed_input == "":
    seed_input = None
MAP = generate_map(seed_input)

MAP_W = len(MAP[0])
MAP_H = len(MAP)

# ----- Player -----
px, py = 3.5, 3.5
pa = 0.0
speed = 0.2
rot_speed = 10

# ----- Screen -----
W, H = 60, 20
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

# ----- Shading ANSI codes (gray-scale) -----
SHADES = ['\033[38;5;236m', '\033[38;5;240m', '\033[38;5;244m', '\033[38;5;248m', '\033[38;5;252m']
RESET = '\033[0m'

# ----- Draw function -----
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
                idx = min(int((y / ceiling) * len(SHADES)), len(SHADES)-1)
                line += SHADES[idx] + '"' + RESET
            elif y <= floor:
                pos_in_wall = y - ceiling
                ratio = pos_in_wall / wall_height
                shade_idx = min(int(distance_to_wall / MAX_DEPTH * (len(SHADES)-1) + ratio*2), len(SHADES)-1)
                line += SHADES[shade_idx] + '█' + RESET
            else:
                floor_distance = (y - H/2) / (H/2)
                idx = min(int(floor_distance * (len(SHADES)-1)), len(SHADES)-1)
                line += SHADES[idx] + '.' + RESET
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
