#!/bin/bash

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

log()    { echo -e "${GREEN}[✔]${RESET} $1"; }
warn()   { echo -e "${YELLOW}[!]${RESET} $1"; }
error()  { echo -e "${RED}[✖]${RESET} $1" >&2; exit 1; }

if [[ $EUID -ne 0 ]]; then
    error "Please run this script as root (sudo bash $0)"
fi

log "Starting MushM Installer"
sleep 1

CROSH="/usr/bin/crosh"
MURK_DIR="/mnt/stateful_partition/murkmod"
MUSHM_URL="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/mushm.sh"

log "Creating directories..."
mkdir -p "$MURK_DIR/mush"
mkdir -p "$MURK_DIR/plugins" "$MURK_DIR/pollen" || error "Failed to create MurkMod directories"
sleep 1

log "Installing MushM"
curl -fsSLo "$CROSH" "$MUSHM_URL" || error "Failed to download MushM"
sleep 1

log "Making add plugins file"
cd /mnt/stateful_partition/murkmod
curl -O https://raw.githubusercontent.com/placeholder

log "Installation complete!"
echo -e "${YELLOW}Made by Star_destroyer11${RESET}"
echo -e "${GREEN}MushM installed. Have Fun${RESET}"
sleep 2



