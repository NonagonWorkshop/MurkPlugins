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

CROSH="/usr/bin/crosh"
LOCAL_DIR="/usr/local/murkmod"
MURK_DIR="/mnt/stateful_partition/murkmod"
MUSH_FILE="$MURK_DIR/mushm.sh"
VERSION_FILE="$MURK_DIR/mushver"
BOOT_MSG="/usr/share/chromeos-assets/text/boot_messages/en/self_repair.txt"
REMOTE_MUSH_URL="https://raw.githubusercontent.com/NonagonWorkshop/MurkPlugins/main/utils/mushm.sh"
REMOTE_CROSH_URL="https://raw.githubusercontent.com/NonagonWorkshop/MurkPlugins/main/utils/mushm.sh"

# Create necessary directories
log "Creating directories..."
mkdir -p "$LOCAL_DIR"
mkdir -p "$MURK_DIR/plugins" "$MURK_DIR/pollen" || error "Failed to create MurkMod directories"

# Initialize version file if missing
if [[ ! -f "$VERSION_FILE" ]]; then
    echo "0.0.0" > "$VERSION_FILE"
    log "Created version file: $VERSION_FILE (0.0.0)"
fi

# Download initial Mush if missing
if [[ ! -f "$MUSH_FILE" ]]; then
    log "Downloading initial Mush..."
    curl -fsSLo "$MUSH_FILE" "$REMOTE_MUSH_URL" || error "Failed to download Mush"
    chmod +x "$MUSH_FILE"
    log "Mush installed at $MUSH_FILE"
else
    log "Mush already exists at $MUSH_FILE"
fi

# Install crosh updater
log "Installing crosh updater..."
curl -fsSLo "$CROSH" "$REMOTE_CROSH_URL" || error "Failed to download crosh updater"
chmod +x "$CROSH"

# Customize boot message
if [[ -w "$(dirname "$BOOT_MSG")" ]]; then
    log "Customizing boot message..."
    cat <<'EOF' > "$BOOT_MSG"
Oops, your system is getting messed up. We don't know why.
Hold tight while we try to repair it...
EOF
else
    warn "Cannot modify boot message (permission denied or path missing)"
fi

log "Installation complete!"
echo -e "${YELLOW}Made by Rainstorm, modified by Star_destroyer11${RESET}"
echo -e "${GREEN}Crosh updater installed. Run 'crosh' to auto-update Mush and launch it.${RESET}"
