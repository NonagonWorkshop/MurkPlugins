#!/bin/bash

LOCAL_PATH="/usr/local/murkmod/mushm.sh"
VERSION_FILE="/mnt/stateful_partition/murkmod/mushver"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/NonagonWorkshop/MurkPlugins/main/utils/mushver"
REMOTE_MUSH_URL="https://raw.githubusercontent.com/NonagonWorkshop/MurkPlugins/main/utils/mushm.sh"
TMP_PATH="/tmp/mushm_latest.sh"

# Ensure required directories exist
mkdir -p "$(dirname "$LOCAL_PATH")"
mkdir -p "$(dirname "$VERSION_FILE")"

echo "Launching Mush..."

# Ensure version file exists
[[ ! -f "$VERSION_FILE" ]] && echo "0.0.0" > "$VERSION_FILE"
LOCAL_VERSION=$(cat "$VERSION_FILE")

# Ensure Mush exists
if [[ ! -f "$LOCAL_PATH" ]]; then
    echo "Mush not found locally."
    if command -v curl >/dev/null 2>&1; then
        echo "Downloading Mush..."
        curl -fsSL "$REMOTE_MUSH_URL" -o "$LOCAL_PATH" || {
            echo "Failed to download Mush. Exiting."
            exit 1
        }
        chmod +x "$LOCAL_PATH"
        [[ ! -f "$VERSION_FILE" ]] && echo "0.0.0" > "$VERSION_FILE"
    else
        echo "No internet connection and Mush missing. Cannot continue."
        exit 1
    fi
fi

# Check internet connectivity before attempting update
if command -v curl >/dev/null 2>&1 && curl -fsSL --head https://github.com >/dev/null 2>&1; then
    REMOTE_VERSION=$(curl -fsSL "$REMOTE_VERSION_URL" 2>/dev/null | tr -d '\r')
    if [[ -n "$REMOTE_VERSION" && "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
        echo "Updating Mush: v$LOCAL_VERSION → v$REMOTE_VERSION"
        [[ -f "$LOCAL_PATH" ]] && cp "$LOCAL_PATH" "$LOCAL_PATH.bak"
        if curl -fsSL "$REMOTE_MUSH_URL" -o "$LOCAL_PATH"; then
            chmod +x "$LOCAL_PATH"
            echo "$REMOTE_VERSION" > "$VERSION_FILE"
            echo "Mush updated successfully."
        else
            echo "Update failed. Using existing Mush."
        fi
    fi
else
    echo "No internet connection detected. Running Mush offline (v$LOCAL_VERSION)."
fi

# Launch Mush
exec bash "$LOCAL_PATH"
