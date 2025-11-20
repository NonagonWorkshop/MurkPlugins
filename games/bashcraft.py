#!/usr/bin/env python3
import sys, tty, termios, math, os

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
pa = 0.0
speed = 0.3
inventory = 0

# ----- Screen -----
W, H = 40, 20
FOV = 60
MAX_DEPTH = 16

# ----- Terminal input -----
def getch():
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
    return ch

# ----- Map helpers -----
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

# ----- Draw function -----
def draw():
    os.system('clear')
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
        if distance == 0: distance = 0.01
        ceiling = int(H/2 - H/distance)
        floor = H - ceiling
        line = ''
        for y in range(H):
            if y < ceiling:
                line += '\033[44m  '  # blue ceiling
            elif y <= floor:
                # wall shading with colors
                if distance < MAX_DEPTH/4:
                    line += '\033[41m██'  # red close
                elif distance < MAX_DEPTH/2:
                    line += '\033[43m▓▓'  # yellow
                elif distance < MAX_DEPTH*3/4:
                    line += '\033[42m▒▒'  # green
                else:
                    line += '\033[40m░░'  # dark
            else:
                line += '\033[46m  '  # cyan floor
        print(line + '\033[0m')
    print(f"Inventory: {inventory}")
    print("Controls: W/S forward/back, A/D rotate, X break, Z place, Q quit")

# ----- Movement -----
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
while True:
    draw()
    key = getch().lower()
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
