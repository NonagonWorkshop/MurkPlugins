#!/usr/bin/env bash
# BashCraft 3D ASCII — fully working in terminal

stty -echo -icanon time 0 min 0
trap "stty sane; printf '\033[?25h'; clear; exit" INT TERM EXIT

printf "\033[2J\033[?25l"  # Clear screen and hide cursor

# Screen & world
W=40
H=20
FOV=1.0472
MAP_W=16
MAP_H=16
MAX_DEPTH=16

# Player
px=8
py=8
pa=0
vx=0
vy=0
speed=0.3
player_hp=10
inventory_stone=0

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

# ---------- Floating point math ----------
fp_add() { awk -v a="$1" -v b="$2" 'BEGIN{print a+b}'; }
fp_sub() { awk -v a="$1" -v b="$2" 'BEGIN{print a-b}'; }
fp_mul() { awk -v a="$1" -v b="$2" 'BEGIN{print a*b}'; }
fp_div() { awk -v a="$1" -v b="$2" 'BEGIN{print a/b}'; }
fp_cos() { awk -v a="$1" 'BEGIN{print cos(a)}'; }
fp_sin() { awk -v a="$1" 'BEGIN{print sin(a)}'; }
fp_round() { awk -v a="$1" 'BEGIN{print int(a+0.5)}'; }

# ---------- Map helpers ----------
get_map() { local x=$1 y=$2; echo "${MAP[$y]:$x:1}"; }
set_map() { local x=$1 y=$2 val=$3; MAP[$y]="${MAP[$y]:0:x}$val${MAP[$y]:x+1}"; }

# ---------- Rendering ----------
draw() {
    printf "\033[H"  # Move cursor to top-left
    for ((x=0;x<W;x++)); do
        ray_angle=$(fp_add "$pa" "$(awk -v w=$W -v i=$x -v f=$FOV 'BEGIN{print f*(i/w-0.5)}')")
        distance_to_wall=0
        hit=0
        while (( hit==0 && distance_to_wall<MAX_DEPTH )); do
            distance_to_wall=$(fp_add "$distance_to_wall" "0.05")
            test_x=$(fp_round "$(fp_add "$px" "$(fp_mul "$distance_to_wall" "$(fp_cos "$ray_angle")")")")
            test_y=$(fp_round "$(fp_add "$py" "$(fp_mul "$distance_to_wall" "$(fp_sin "$ray_angle")")")")
            [[ "$(get_map $test_x $test_y)" == "#" ]] && hit=1
        done
        ceiling=$((H/2 - H/distance_to_wall))
        floor=$((H - ceiling))
        for ((y=0;y<H;y++)); do
            if ((y<ceiling)); then
                printf "\033[44m^^"  # Ceiling
            elif ((y>=ceiling && y<=floor)); then
                if (( distance_to_wall < MAX_DEPTH/4 )); then color=196; char="██"
                elif (( distance_to_wall < MAX_DEPTH/2 )); then color=202; char="▓▓"
                elif (( distance_to_wall < MAX_DEPTH*3/4 )); then color=220; char="▒▒"
                else color=238; char="░░"
                fi
                printf "\033[48;5;%dm%s" "$color" "$char"
            else
                printf "\033[42m::"  # Floor
            fi
        done
        printf "\033[0m\n"
    done
    printf "\033[0mHP:%d Stone:%d\n" "$player_hp" "$inventory_stone"
    printf "Controls: W/S forward/back, A/D rotate, X break, Z place, Q quit\n"
}

# ---------- Movement ----------
update_velocity() {
    local cx=$(fp_cos "$pa")
    local sy=$(fp_sin "$pa")
    vx=$(fp_mul "$cx" "$speed")
    vy=$(fp_mul "$sy" "$speed")
}

move_player() {
    local nx=$(fp_add "$px" "$vx")
    local ny=$(fp_add "$py" "$vy")
    if [[ "$(get_map ${nx%.*} ${ny%.*})" != "#" ]]; then
        px=$nx
        py=$ny
    fi
}

move_backward() {
    local nx=$(fp_sub "$px" "$vx")
    local ny=$(fp_sub "$py" "$vy")
    if [[ "$(get_map ${nx%.*} ${ny%.*})" != "#" ]]; then
        px=$nx
        py=$ny
    fi
}

# ---------- Block interaction ----------
break_block() {
    bx=$((px))
    by=$((py))
    [[ "$(get_map $bx $by)" == "#" ]] && set_map $bx $by "." && inventory_stone=$((inventory_stone+1))
}

place_block() {
    bx=$((px+1))
    by=$((py))
    [[ "$inventory_stone" -gt 0 && "$(get_map $bx $by)" == "." ]] && set_map $bx $by "#" && inventory_stone=$((inventory_stone-1))
}

# ---------- Main loop ----------
while true; do
    draw
    read -rsn1 key
    case "$key" in
        w|W) update_velocity; move_player ;;
        s|S) update_velocity; move_backward ;;
        a|A) pa=$(fp_sub "$pa" "0.2") ;;
        d|D) pa=$(fp_add "$pa" "0.2") ;;
        x|X) break_block ;;
        z|Z) place_block ;;
        q|Q) break ;;
    esac
done

stty sane
printf "\033[?25h"  # Show cursor
clear
