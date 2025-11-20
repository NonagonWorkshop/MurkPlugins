#!/bin/bash
# Enhanced BashCraft 3D — Pure Bash, basic commands only

stty -echo -icanon time 0 min 0
trap "stty sane; clear; exit" INT TERM EXIT

printf "\033[2J\033[?25l"  # Clear & hide cursor

# Settings
W=40
H=20
FOV=60
MAX_DEPTH=16
SCALE=1000

# Player
px=$((8*SCALE))
py=$((8*SCALE))
pa=0
speed=$((300))  # 0.3 scaled
inventory=0

# Map
MAP=(
"################"
"#..............#"
"#..##..........#"
"#..............#"
"#......##......#"
"#..............#"
"#....#.........#"
"#..............#"
"#..............#"
"#..............#"
"#..............#"
"#..............#"
"#..............#"
"#..............#"
"#..............#"
"################"
)

# Fixed-point math
fp_add() { echo $(( $1 + $2 )); }
fp_sub() { echo $(( $1 - $2 )); }
fp_mul() { echo $(( ($1 * $2) / SCALE )); }

fp_sin() {
    deg=$(( $1 % 360 ))
    case $deg in
        0) echo 0 ;;
        30) echo 500 ;;
        45) echo 707 ;;
        60) echo 866 ;;
        90) echo 1000 ;;
        120) echo 866 ;;
        135) echo 707 ;;
        150) echo 500 ;;
        180) echo 0 ;;
        210) echo -500 ;;
        225) echo -707 ;;
        240) echo -866 ;;
        270) echo -1000 ;;
        300) echo -866 ;;
        315) echo -707 ;;
        330) echo -500 ;;
        *) echo 0 ;;
    esac
}
fp_cos() { fp_sin $((90 - $1)); }

# Map helpers
get_map() { local x=$1 y=$2; echo "${MAP[$y]:$x:1}"; }
set_map() { local x=$1 y=$2 val=$3; MAP[$y]="${MAP[$y]:0:x}$val${MAP[$y]:x+1}"; }

# Rendering
draw() {
    printf "\033[H"
    for ((x=0;x<W;x++)); do
        ray_angle=$((pa - FOV/2 + x*FOV/W))
        distance=0
        hit=0
        while (( hit==0 && distance<MAX_DEPTH*SCALE )); do
            dx=$(fp_mul $distance $(fp_cos $ray_angle))
            dy=$(fp_mul $distance $(fp_sin $ray_angle))
            mapx=$(( (px + dx)/SCALE ))
            mapy=$(( (py + dy)/SCALE ))
            [[ "$(get_map $mapx $mapy)" == "#" ]] && hit=1
            distance=$((distance + 50))
        done

        ceiling=$(( H/2 - H*distance/(MAX_DEPTH*SCALE) ))
        floor=$(( H - ceiling ))

        for ((y=0;y<H;y++)); do
            if ((y<ceiling)); then
                printf "\033[44m^^"
            elif ((y>=ceiling && y<=floor)); then
                if (( distance < MAX_DEPTH*SCALE/4 )); then char="\033[41m██"   # close wall red
                elif (( distance < MAX_DEPTH*SCALE/2 )); then char="\033[43m▓▓"   # medium wall yellow
                elif (( distance < MAX_DEPTH*SCALE*3/4 )); then char="\033[42m▒▒" # far wall green
                else char="\033[40m░░"                                           # very far wall dark
                fi
                printf "$char"
            else
                printf "\033[46m::"  # Floor blue
            fi
        done
        printf "\033[0m\n"
    done

    # Simple minimap
    echo "Inventory: $inventory   Controls: W/S forward/back, A/D rotate, X break, Z place, Q quit"
    for ((y=0;y<16;y++)); do
        for ((x=0;x<16;x++)); do
            if (( x == px/SCALE && y == py/SCALE )); then
                printf "\033[41m@"      # player on minimap
            else
                c=$(get_map $x $y)
                if [[ "$c" == "#" ]]; then printf "\033[47m " 
                else printf "\033[40m." 
                fi
            fi
        done
        printf "\033[0m\n"
    done
}

# Movement
update_velocity() {
    vx=$(fp_mul $speed $(fp_cos $pa))
    vy=$(fp_mul $speed $(fp_sin $pa))
}

move_forward() {
    nx=$((px + vx))
    ny=$((py + vy))
    mapx=$(( nx / SCALE ))
    mapy=$(( ny / SCALE ))
    [[ "$(get_map $mapx $mapy)" != "#" ]] && px=$nx && py=$ny
}

move_backward() {
    nx=$((px - vx))
    ny=$((py - vy))
    mapx=$(( nx / SCALE ))
    mapy=$(( ny / SCALE ))
    [[ "$(get_map $mapx $mapy)" != "#" ]] && px=$nx && py=$ny
}

break_block() {
    mapx=$(( px / SCALE ))
    mapy=$(( py / SCALE ))
    [[ "$(get_map $mapx $mapy)" == "#" ]] && set_map $mapx $mapy "." && inventory=$((inventory+1))
}

place_block() {
    mapx=$(( px / SCALE ))
    mapy=$(( py / SCALE ))
    [[ "$inventory" -gt 0 && "$(get_map $mapx $mapy)" == "." ]] && set_map $mapx $mapy "#" && inventory=$((inventory-1))
}

# Main loop
clear
while true; do
    draw
    read -rsn1 key
    case "$key" in
        w|W) update_velocity; move_forward ;;
        s|S) update_velocity; move_backward ;;
        a|A) pa=$(( (pa - 15 + 360) % 360 )) ;;
        d|D) pa=$(( (pa + 15) % 360 )) ;;
        x|X) break_block ;;
        z|Z) place_block ;;
        q|Q) break ;;
    esac
done

stty sane
clear
printf "\033[?25h"
