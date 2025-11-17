#!/bin/bash

GREEN="\033[1;32m"
CYAN="\033[1;36m"
MAGENTA="\033[1;35m"
RESET="\033[0m"

section() {
    echo -e "${MAGENTA}--- $1 ---${RESET}"
}

field() {
    printf "${GREEN}%-25s${RESET} %s\n" "$1" "${2:-N/A}"
}

bool() {
    [ "$1" = "1" ] && echo "Enabled" || echo "Disabled"
}

get_chromeos_version() {
    CHROMEOS=$(grep "CHROMEOS_VERSION" /etc/lsb-release 2>/dev/null | cut -d= -f2)
    echo "${CHROMEOS:-N/A}"
}

get_channel() {
    CHANNEL=$(grep "CHROMEOS_CHANNEL" /etc/lsb-release 2>/dev/null | cut -d= -f2)
    echo "${CHANNEL:-N/A}"
}

get_sid() {
    SID=$(dmidecode -s system-uuid 2>/dev/null)
    echo "${SID:-N/A}"
}

get_ram() {
    RAM=$(free -h | grep Mem | awk '{print $2}')
    echo "${RAM:-N/A}"
}

get_cpu() {
    CPU=$(lscpu | grep "Model name" | cut -d: -f2 | sed 's/^[ \t]*//')
    echo "${CPU:-N/A}"
}

get_disk() {
    DISK=$(df -h / | tail -n 1 | awk '{print $2}')
    echo "${DISK:-N/A}"
}

get_kernel() {
    KERNEL=$(uname -r)
    echo "${KERNEL:-N/A}"
}

KERNEL=$(get_kernel)
CHROMEOS_VER=$(get_chromeos_version)
CHANNEL=$(get_channel)
HWID=$(crossystem hwid 2>/dev/null)
FWID=$(crossystem fwid 2>/dev/null)
SERIAL=$(crossystem serial_number 2>/dev/null)
SID=$(get_sid)

DEV_MODE=$(bool "$(crossystem devsw_boot 2>/dev/null)")
HWWP=$(bool "$(crossystem wpsw_cur 2>/dev/null)")
SWWP=$(bool "$(crossystem wpsw_boot 2>/dev/null)")

FLASH_LOCK=$(flashrom --wp-status 2>/dev/null | grep "mode" | awk '{print $3}' || echo "N/A")

TPM_ENABLED=$(tpm_manager_client status 2>/dev/null | grep "enabled" | awk '{print $2}' | tr -d : || echo "N/A")
TPM_OWNED=$(tpm_manager_client status 2>/dev/null | grep "owned" | awk '{print $2}' | tr -d : || echo "N/A")

RAM=$(get_ram)
CPU=$(get_cpu)
DISK=$(get_disk)

echo -e "${CYAN}"
echo "==============================================="
echo "          ChromeOS System Summary"
echo "==============================================="
echo -e "${RESET}"

section "System"
field "Kernel" "$KERNEL"
field "ChromeOS Version" "$CHROMEOS_VER"
field "ChromeOS Channel" "$CHANNEL"
field "System SID" "$SID"

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

section "System Resources"
field "RAM" "$RAM"
field "CPU" "$CPU"
field "Disk Space" "$DISK"

echo ""
echo -e "${CYAN}==============================================="
echo -e "                   Done"
echo -e "===============================================${RESET}"
pause
