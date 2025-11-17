#!/bin/bash

GREEN="\033[1;32m"
CYAN="\033[1;36m"
MAGENTA="\033[1;35m"
RESET="\033[0m"

section() {
    echo -e "${MAGENTA}--- $1 ---${RESET}"
}

field() {
    printf "${GREEN}%-20s${RESET} %s\n" "$1" "${2:-N/A}"
}

bool() {
    [ "$1" = "1" ] && echo "Enabled" || echo "Disabled"
}

echo -e "${CYAN}"
echo "==============================================="
echo "          ChromeOS System Summary"
echo "==============================================="
echo -e "${RESET}"

# Basic Info
KERNEL="$(uname -r)"
CHROMEOS="$(lsb_release -d 2>/dev/null | cut -f2)"
HWID="$(crossystem hwid 2>/dev/null)"
FWID="$(crossystem fwid 2>/dev/null)"
SERIAL="$(crossystem serial_number 2>/dev/null)"

# Security
DEV_MODE="$(bool "$(crossystem devsw_boot 2>/dev/null)")"
HWWP="$(bool "$(crossystem wpsw_cur 2>/dev/null)")"
SWWP="$(bool "$(crossystem wpsw_boot 2>/dev/null)")"

# Flash status (short)
FLASH_LOCK=$(flashrom --wp-status 2>/dev/null | grep "mode" | awk '{print $3}' || echo "N/A")

# TPM (short summary)
TPM_ENABLED=$(tpm_manager_client status 2>/dev/null | grep "enabled" | awk '{print $2}' | tr -d : || echo "N/A")
TPM_OWNED=$(tpm_manager_client status 2>/dev/null | grep "owned" | awk '{print $2}' | tr -d : || echo "N/A")

section "System"
field "Kernel" "$KERNEL"
field "ChromeOS Ver" "$CHROMEOS"

section "Hardware"
field "HWID" "$HWID"
field "FWID" "$FWID"
field "Serial" "$SERIAL"

section "Security"
field "Developer Mode" "$DEV_MODE"
field "HW Write-Protect" "$HWWP"
field "SW Write-Protect" "$SWWP"

section "Flash Status"
field "Flash Lock" "$FLASH_LOCK"

section "TPM"
field "TPM Enabled" "$TPM_ENABLED"
field "TPM Owned" "$TPM_OWNED"

echo ""
echo -e "${CYAN}==============================================="
echo -e "                   Done"
echo -e "===============================================${RESET}"
