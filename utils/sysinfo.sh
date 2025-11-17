#!/bin/bash

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

echo -e "${CYAN}"
echo "==============================================="
echo "          ChromeOS Detailed System Info        "
echo "==============================================="
echo -e "${RESET}"

section() {
    echo -e "${MAGENTA}--- $1 ---${RESET}"
}

field() {
    printf "${GREEN}%-25s${RESET} %s\n" "$1" "$2"
}

bool_to_text() {
    if [ "$1" = "1" ]; then
        echo "Enabled"
    else
        echo "Disabled"
    fi
}

KERNEL="$(uname -a)"
CHROMEOS_VERSION="$(lsb_release -a 2>/dev/null | grep 'Description' | cut -d: -f2)"
HWID="$(crossystem hwid)"
FWID="$(crossystem fwid)"
SERIAL="$(crossystem serial_number)"
DEV_MODE="$(bool_to_text $(crossystem devsw_boot))"
HWWP="$(bool_to_text $(crossystem wpsw_cur))"
SWWP="$(bool_to_text $(crossystem wpsw_boot))"
FLASHWP="$(flashrom --wp-status 2>/dev/null)"
FWMP="$(crossystem --all | grep fwmp)"
ECINFO="$(mosys ec info 2>/dev/null)"
TPMINFO="$(tpm_manager_client status 2>/dev/null)"

section "System"
field "Kernel" "$KERNEL"
field "ChromeOS Version" "$CHROMEOS_VERSION"

echo ""
section "Hardware"
field "HWID (Device Model)" "$HWID"
field "FWID (Board/Firmware)" "$FWID"
field "Serial Number" "$SERIAL"

echo ""
section "Security / Boot"
field "Dev Mode" "$DEV_MODE"
field "HW Write-Protect" "$HWWP"
field "SW Write-Protect" "$SWWP"

echo ""
section "Flash WP"
echo -e "${WHITE}$FLASHWP${RESET}"

echo ""
section "FWMP Status"
echo -e "${WHITE}$FWMP${RESET}"

echo ""
section "EC Info"
echo -e "${WHITE}$ECINFO${RESET}"

echo ""
section "TPM Status"
echo -e "${WHITE}$TPMINFO${RESET}"

echo ""
echo -e "${CYAN}==============================================="
echo -e "                    Done"
echo -e "===============================================${RESET}"
