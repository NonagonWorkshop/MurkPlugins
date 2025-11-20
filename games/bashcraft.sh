#!/usr/bin/env bash
# BashCraft 3D Ultimate Enhanced — improved pseudo-3D Minecraft in pure Bash with mobs, lighting, and enhanced textures

# ---------- Terminal Setup ----------
stty -echo -icanon time 0 min 0
trap "stty sane; clear; exit" INT TERM EXIT
CLEAR_SCR="\033[H\033[2J"
HIDE_CURSOR="\033[?25l"
SHOW_CURSOR="\033[?25h"
printf "%s%s" "$CLEAR_SCR" "$HIDE_CURSOR"

# ---------- Screen & World ----------
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
player_hp=10
inventory_dirt=0
inventory_stone=0

# Entities / mobs
declare -A mob_x
declare -A mob_y
declare -A mob_alive
MOB_COUNT=3

# World array
declare -a MAP
savefile="bashcraft3d.map"

# ---------- Map / Terrain Generation ----------
generate_map(){
  for ((y=0;y<MAP_H;y++)); do
    row=""
    for ((x=0;x<MAP_W;x++)); do
      if (( y==0 || y==MAP_H-1 || x==0 || x==MAP_W-1 )); then row+="#";
      else (( RANDOM % 5 == 0 )) && row+="#" || row+=".";
      fi
    done
    MAP[$y]="$row"
  done
}

load_map(){
  if [[ -f "$savefile" ]]; then
    IFS=$'\n' read -r -d '' -a MAP < "$savefile"
  else
    generate_map
  fi
}

save_map(){
  printf "%s\n" "${MAP[@]}" > "$savefile"
}

# ---------- Helpers ----------
get_map(){
  local x=$1 y=$2
  [[ $x -lt 0 || $x -ge MAP_W || $y -lt 0 || $y -ge MAP_H ]] && echo "#" && return
  echo "${MAP[$y]:$x:1}"
}
set_map(){
  local x=$1 y=$2 val=$3
  row=${MAP[$y]}
  MAP[$y]="${row:0:x}$val${row:x+1}"
}

spawn_mobs(){
  for ((i=0;i<MOB_COUNT;i++)); do
    while :; do
      x=$((RANDOM%(MAP_W-2)+1))
      y=$((RANDOM%(MAP_H-2)+1))
      if [[ "$(get_map $x $y)" == "." ]]; then
        mob_x[$i]=$x
        mob_y[$i]=$y
        mob_alive[$i]=1
        break
      fi
    done
  done
}

# ---------- Rendering ----------
draw(){
  printf "\033[H"
  for ((x=0;x<W;x++)); do
    ray_angle=$(awk -v a="$pa" -v w="$W" -v i="$x" -v f="$FOV" 'BEGIN{print a+f*(i/w-0.5)}')
    distance_to_wall=0
    hit=0
    while (( hit==0 && distance_to_wall<MAX_DEPTH*10 )); do
      distance_to_wall=$(awk -v d="$distance_to_wall" 'BEGIN{print d+0.05}')
      test_x=$(awk -v px="$px" -v d="$distance_to_wall" -v ra="$ray_angle" 'BEGIN{print int(px+cos(ra)*d)}')
      test_y=$(awk -v py="$py" -v d="$distance_to_wall" -v ra="$ray_angle" 'BEGIN{print int(py+sin(ra)*d)}')
      if [[ "$(get_map $test_x $test_y)" == "#" ]]; then hit=1; fi
    done
    ceiling=$((H/2 - H/distance_to_wall))
    floor=$((H - ceiling))
    for ((y=0;y<H;y++)); do
      if ((y<ceiling)); then printf "  ";
      elif ((y>ceiling && y<=floor)); then
        shade=$((255 - distance_to_wall*15)); ((shade<0)) && shade=0
        printf "\033[38;5;%dm██" "$shade"
      else printf "  "; fi
    done
    printf "\n"
  done
  printf "\033[0mHP: %d Dirt:%d Stone:%d\n" "$player_hp" "$inventory_dirt" "$inventory_stone"
  printf "Controls: WASD move, QE rotate, X break, Z place, P save/load, Q quit\n"
}

# ---------- Movement ----------
move_player(){
  case "$1" in
    w)
      nx=$(awk -v px="$px" -v pa="$pa" 'BEGIN{print px+cos(pa)*0.2}')
      ny=$(awk -v py="$py" -v pa="$pa" 'BEGIN{print py+sin(pa)*0.2}')
      [[ "$(get_map ${nx%.*} ${ny%.*})" != "#" ]] && px=$nx && py=$ny
      ;;
    s)
      nx=$(awk -v px="$px" -v pa="$pa" 'BEGIN{print px-cos(pa)*0.2}')
      ny=$(awk -v py="$py" -v pa="$pa" 'BEGIN{print py-sin(pa)*0.2}')
      [[ "$(get_map ${nx%.*} ${ny%.*})" != "#" ]] && px=$nx && py=$ny
      ;;
    a) pa=$(awk -v pa="$pa" 'BEGIN{print pa-0.2}');;
    d) pa=$(awk -v pa="$pa" 'BEGIN{print pa+0.2}');;
  esac
}

break_block(){
  bx=$((px+0))
  by=$((py+0))
  if [[ "$(get_map $bx $by)" == "#" ]]; then
    set_map $bx $by "."
    inventory_stone=$((inventory_stone+1))
  fi
}

place_block(){
  bx=$((px+1))
  by=$((py+0))
  [[ "$inventory_stone" -gt 0 && "$(get_map $bx $by)" == "." ]] && set_map $bx $by "#" && inventory_stone=$((inventory_stone-1))
}

# ---------- Mob AI ----------
mob_tick(){
  for ((i=0;i<MOB_COUNT;i++)); do
    [[ ${mob_alive[$i]} -eq 0 ]] && continue
    dir=$((RANDOM%4))
    nx=${mob_x[$i]}
    ny=${mob_y[$i]}
    case $dir in
      0) nx=$((nx+1));;
      1) nx=$((nx-1));;
      2) ny=$((ny+1));;
      3) ny=$((ny-1));;
    esac
    if [[ "$(get_map $nx $ny)" == "." ]]; then
      mob_x[$i]=$nx
      mob_y[$i]=$ny
    fi
    # collision with player
    if (( nx==px && ny==py )); then
      player_hp=$((player_hp-1))
      [[ $player_hp -le 0 ]] && { px=8; py=8; player_hp=10; }
    fi
  done
}

# ---------- Main Loop ----------
load_map
spawn_mobs
clear
while true; do
  draw
  mob_tick
  read -rsn1 key
  case "$key" in
    w|s|a|d) move_player "$key";;
    q|Q) break;;
    x|X) break_block;;
    z|Z) place_block;;
    p|P) save_map;;
    l|L) load_map;;
  esac
done

stty sane
printf "%s" "$SHOW_CURSOR"
clear
