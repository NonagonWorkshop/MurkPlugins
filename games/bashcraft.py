#!/usr/bin/env python3
import math, sys, tty, termios, os

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

MAP_W = len(MAP[0])
MAP_H = len(MAP)

# ----- Player -----
px, py = 8.0, 8.0
pa = 0.0
speed = 0.3
inventory = 0

# ----- Screen -----
W, H = 40, 20
FOV = 60
MAX_DEPTH = 16

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
    x = int(x)
    y = int(y)
    if 0<=x<MAP_W and 0<=y<MAP_H: return MAP[y][x]
    return '#'

def set_map(x,y,val):
    x=int(x)
    y=int(y)
    MAP[y] = MAP[y][:x]+val+MAP[y][x+1:]

# ----- Draw -----
def draw():
    os.system('clear')
    for y in range(H):
        line = ""
        for x in range(W):
            # compute ray for this column
            ray_angle = math.radians(pa - FOV/2 + x*FOV/W)
            distance_to_wall = 0.0
            hit = False
            while not hit and distance_to_wall < MAX_DEPTH:
                distance_to_wall += 0.05
                test_x = px + distance_to_wall * math.cos(ray_angle)
                test_y = py + distance_to_wall * math.sin(ray_angle)
                if get_map(test_x,test_y) == '#':
                    hit = True
            # compute wall height
            if distance_to_wall==0: distance_to_wall=0.01
            ceiling = int(H/2 - H/distance_to_wall)
            floor = H - ceiling
            if y < ceiling:
                line += '  '
            elif y <= floor:
                if distance_to_wall < MAX_DEPTH/4:
                    line += '\033[41m██'  # close red
                elif distance_to_wall < MAX_DEPTH/2:
                    line += '\033[43m▓▓'
                elif distance_to_wall < MAX_DEPTH*3/4:
                    line += '\033[42m▒▒'
                else:
                    line += '\033[40m░░'
            else:
                line += '  '
        line += '\033[0m'
        print(line)
    print(f"Inventory: {inventory} | Controls: W/S/A/D X/Z Q")

# ----- Movement -----
def move(dx,dy):
    global px,py
    nx,ny = px+dx, py+dy
    if get_map(nx,ny) != '#':
        px,py = nx,ny

def break_block():
    global inventory
    bx,by=int(px),int(py)
    if get_map(bx,by)=='#':
        set_map(bx,by,'.')
        inventory+=1

def place_block():
    global inventory
    bx,by=int(px),int(py)
    if inventory>0 and get_map(bx,by)=='.':
        set_map(bx,by,'#')
        inventory-=1

# ----- Main loop -----
while True:
    draw()
    key = getch().lower()
    if key=='w':
        move(math.cos(math.radians(pa))*speed, math.sin(math.radians(pa))*speed)
    elif key=='s':
        move(-math.cos(math.radians(pa))*speed, -math.sin(math.radians(pa))*speed)
    elif key=='a':
        pa=(pa-15)%360
    elif key=='d':
        pa=(pa+15)%360
    elif key=='x':
        break_block()
    elif key=='z':
        place_block()
    elif key=='q':
        break
