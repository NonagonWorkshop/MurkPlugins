#!/usr/bin/env python3
# Terminal Minecraft Clone — Raycasting 3D, ASCII, colors, pure Python

import math
import sys
import time

# ----- Map -----
MAP = [
    "################",
    "#..............#",
    "#..##..........#",
    "#..............#",
    "#......##......#",
    "#..............#",
    "#....#.........#",
    "#..............#",
    "#..............#",
    "#..............#",
    "#..............#",
    "#..............#",
    "#..............#",
    "#..............#",
    "#..............#",
    "################"
]

MAP_WIDTH = len(MAP[0])
MAP_HEIGHT = len(MAP)

# ----- Player -----
px, py = 8.0, 8.0
pa = 0.0  # angle in degrees
speed = 0.3
inventory = 0

# ----- Screen -----
W, H = 40, 20  # columns, rows
FOV = 60       # field of view in degrees
MAX_DEPTH = 16

# ----- Functions -----
def clear_screen():
    print("\033[2J\033[H", end='')

def get_map(x, y):
    x = int(x)
    y = int(y)
    if 0 <= x < MAP_WIDTH and 0 <= y < MAP_HEIGHT:
        return MAP[y][x]
    return '#'

def set_map(x, y, val):
    x = int(x)
    y = int(y)
    MAP[y] = MAP[y][:x] + val + MAP[y][x+1:]

def draw():
    lines = []
    for x in range(W):
        ray_angle = math.radians(pa - FOV/2 + x*FOV/W)
        distance = 0.0
        hit = False
        while not hit and distance < MAX_DEPTH:
            distance += 0.05
            test_x = px + distance * math.cos(ray_angle)
            test_y = py + distance * math.sin(ray_angle)
            if get_map(test_x, test_y) == '#':
                hit = True
        # Project wall height
        if distance == 0: distance = 0.01
        ceiling = int(H/2 - H/distance)
        floor = H - ceiling
        line = ''
        for y in range(H):
            if y < ceiling:
                line += '\033[44m^^'  # ceiling blue
            elif y <= floor:
                # Wall shading by distance
                if distance < MAX_DEPTH/4:
                    line += '\033[41m██'  # close wall red
                elif distance < MAX_DEPTH/2:
                    line += '\033[43m▓▓'  # medium wall yellow
                elif distance < MAX_DEPTH*3/4:
                    line += '\033[42m▒▒'  # far wall green
                else:
                    line += '\033[40m░░'  # very far wall dark
            else:
                line += '\033[46m::'  # floor cyan
        lines.append(line + '\033[0m')
    print("\033[H", end='')
    for line in lines:
        print(line)
    print(f"Inventory: {inventory}")
    print("Controls: W/S forward/back, A/D rotate, X break, Z place, Q quit")

def move(dx, dy):
    global px, py
    nx, ny = px + dx, py + dy
    if get_map(nx, ny) != '#':
        px, py = nx, ny

def break_block():
    global inventory
    bx, by = int(px), int(py)
    if get_map(bx, by) == '#':
        set_map(bx, by, '.')
        inventory += 1

def place_block():
    global inventory
    bx, by = int(px), int(py)
    if inventory > 0 and get_map(bx, by) == '.':
        set_map(bx, by, '#')
        inventory -= 1

# ----- Main loop -----
clear_screen()
while True:
    draw()
    key = input("Command: ").lower()
    if key == 'w':
        move(math.cos(math.radians(pa))*speed, math.sin(math.radians(pa))*speed)
    elif key == 's':
        move(-math.cos(math.radians(pa))*speed, -math.sin(math.radians(pa))*speed)
    elif key == 'a':
        pa = (pa - 15) % 360
    elif key == 'd':
        pa = (pa + 15) % 360
    elif key == 'x':
        break_block()
    elif key == 'z':
        place_block()
    elif key == 'q':
        break
