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
BOOTMSG_URL="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/bootmsg.sh"
START_BOOT_URL="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/nonamod.conf"


log "Creating directories..."
mkdir -p "$MURK_DIR/mush"
mkdir -p "$MURK_DIR/plugins" "$MURK_DIR/pollen" || error "Failed to create MurkMod directories"
sleep 1

log "Installing MushM"
curl -fsSLo "$CROSH" "$MUSHM_URL" || error "Failed to download MushM"
sleep 1

Log "Fixing Weard Boot Message"
curl -fsSL "$BOOTMSG_URL" || error "Failed to download Boot Message Fixer"
cp bootmsg.sh /usr/local/bin/
chmod +x /usr/local/bin/bootmsg.sh
sleep 1

log "Adding Boot Script"
curl -fsSL "$START_BOOT_URL" || error "Failed to download Boot Script"
cp nonamod.conf /etc/init/
touch /var/log/nonamod.log

sleep 1

log "Installation complete!"
echo -e "${YELLOW}Made by Star_destroyer11${RESET}"
echo -e "${GREEN}MushM installed. Have Fun${RESET}"
