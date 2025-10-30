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

log "Starting MurkMod Installer"
cd /usr/bin || error "Failed to cd into /usr/bin"

if [[ -f "crosh" ]]; then
    log "Creating crosh backup..."
    cp crosh crosh.bak || error "Failed to create backup!"
else
    warn "crosh not found — skipping backup"
fi

log "Downloading MushM..."
curl -fsSLO https://raw.githubusercontent.com/NonagonWorkshop/MurkPlugins/main/utils/mushm.sh || error "Failed to download mushm.sh"

if [[ -f "mushm.sh" ]]; then
    log "Replacing crosh with MushM..."
    cp mushm.sh crosh || error "Failed to overwrite crosh"
else
    error "mushm.sh not found after download!"
fi

log "Creating MurkMod folders..."
mkdir -p /mnt/stateful_partition/murkmod/{plugins,pollen} || error "Failed to create MurkMod directories"

BOOT_MSG="/usr/share/chromeos-assets/text/boot_messages/en/self_repair.txt"
if [[ -w "$(dirname "$BOOT_MSG")" ]]; then
    log "Customizing UwU error message..."
    cat <<'EOF' > "$BOOT_MSG"
Oops, your system is getting messed up. We don't know why.
Hold tight while we try to repair it... UwU 💀
EOF
else
    warn "Cannot modify boot message (permission denied or path missing)"
fi

rm -f /usr/bin/mushm.sh

log "Installation complete!"
echo -e "${YELLOW}Made by Rainstorm, modified by Star_destroyer11${RESET}"
echo -e "${GREEN}Have fun with your modded ChromeOS!${RESET}"
