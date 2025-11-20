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
W, H = 40, 20
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
def get_map(x,y):
    x=int(x)
    y=int(y)
    if 0<=x<MAP_W and 0<=y<MAP_H:
        return MAP[y][x]
    return '#'

# ----- Draw function -----
def draw():
    os.system('clear')
    for y in range(H):
        line = ""
        for x in range(W):
            # Compute ray angle
            ray_angle = math.radians(pa - FOV/2 + x*FOV/W)
            distance_to_wall = 0.0
            hit = False
            while not hit and distance_to_wall < MAX_DEPTH:
                distance_to_wall += 0.05
                test_x = px + distance_to_wall * math.cos(ray_angle)
                test_y = py + distance_to_wall * math.sin(ray_angle)
                if get_map(test_x,test_y) == '#':
                    hit = True
            if distance_to_wall == 0: distance_to_wall = 0.01

            # Project wall height
            wall_height = int(H / distance_to_wall)
            ceiling = H//2 - wall_height//2
            floor = H//2 + wall_height//2

            # Draw ceiling
            if y < ceiling:
                line += '\033[34m"'  # blue ceiling
            # Draw wall with shading based on distance
            elif y <= floor:
                if distance_to_wall < MAX_DEPTH/4:
                    line += '\033[31m█'  # close wall red
                elif distance_to_wall < MAX_DEPTH/2:
                    line += '\033[32m▓'  # mid wall green
                elif distance_to_wall < MAX_DEPTH*3/4:
                    line += '\033[33m▒'  # far wall yellow
                else:
                    line += '\033[90m░'  # very far dark gray
            # Draw floor
            else:
                line += '\033[35m.'  # purple floor
        line += '\033[0m'
        print(line)

# ----- Movement -----
def move(dx,dy):
    global px, py
    nx, ny = px + dx, py + dy
    if get_map(nx, ny) != '#':
        px, py = nx, ny

# ----- Main loop -----
while True:
    draw()
    key = getch().lower()
    if key=='w':
        move(math.cos(math.radians(pa))*speed, math.sin(math.radians(pa))*speed)
    elif key=='s':
        move(-math.cos(math.radians(pa))*speed, -math.sin(math.radians(pa))*speed)
    elif key=='a':
        pa = (pa - 10) % 360
    elif key=='d':
        pa = (pa + 10) % 360
    elif key=='q':
        break
