#!/bin/bash

get_largest_cros_blockdev() {
    local largest size dev_name tmp_size remo
    size=0
    for blockdev in /sys/block/*; do
        dev_name="${blockdev##*/}"
        echo "$dev_name" | grep -q '^\(loop\|ram\)' && continue
        tmp_size=$(cat "$blockdev"/size)
        remo=$(cat "$blockdev"/removable)
        if [ "$tmp_size" -gt "$size" ] && [ "${remo:-0}" -eq 0 ]; then
            case "$(doas sfdisk -l -o name "/dev/$dev_name" 2>/dev/null)" in
                *STATE*KERN-A*ROOT-A*KERN-B*ROOT-B*)
                    largest="/dev/$dev_name"
                    size="$tmp_size"
                    ;;
            esac
        fi
    done
    echo "$largest"
}

traps() {
    set +e
    trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
    trap 'echo \"${last_command}\" command failed with exit code $? - press a key to exit.' EXIT
    trap '' INT
}

mushm_info() {
    echo -ne "\033]0;mushM\007"
    if [ ! -f /mnt/stateful_partition/custom_greeting ]; then
        cat <<-EOF
Welcome to mushM, A Custom Developer Shell for MurkMod

If you ended up here by accident, don’t worry! Simply close this tab and you’ll be good to go.

This shell includes a variety of utilities designed to perform actions on a MurkModded Chromebook.

Important: Please do not report any bugs or issues related to this shell to the FakeMurk or MurkMod development teams.
It’s an independent tool and not officially supported by them.

EOF
    else
        cat /mnt/stateful_partition/custom_greeting
    fi
}

doas() {
    ssh -t -p 1337 -i /rootkey -oStrictHostKeyChecking=no root@127.0.0.1 "$@"
}

runjob() {
    clear
    trap 'kill -2 $! >/dev/null 2>&1' INT
    (
        # shellcheck disable=SC2068
        $@
    )
    trap '' INT
    clear
}

swallow_stdin() {
    while read -t 0 notused; do
        read input
    done
}

edit() {
    if doas which nano 2>/dev/null; then
        doas nano "$@"
    else
        doas vi "$@"
    fi
}

locked_main() {
    traps
    mushm_info
    while true; do
        echo -ne "\033]0;mushm\007"
        cat <<-EOF
(1) Emergency Revert & Re-Enroll
(2) Soft Disable Extensions
(3) Hard Disable Extensions
(4) Hard Enable Extensions
(5) Enter Admin Mode (Password-Protected)
(6) Check for updates Murkmod
EOF
        
        swallow_stdin
        read -r -p "> (1-5): " choice
        case "$choice" in
        1) runjob revert ;;
        2) runjob softdisableext ;;
        3) runjob harddisableext ;;
        4) runjob hardenableext ;;
        5) runjob prompt_passwd ;;
        6) runjob do_updates && exit 0 ;;


        *) echo && echo "Invalid option, dipshit." && echo ;;
        esac
    done
}

main() {
    traps
    mushm_info
    while true; do
        echo -ne "\033]0;mushm\007"
        cat <<-EOF
(1) Root Shell
(2) Chronos Shell
(3) Crosh
(4) Plugins
(5) Install plugins
(6) Uninstall plugins
(7) Powerwash
(8) Emergency Revert & Re-Enroll
(9) Soft Disable Extensions
(10) Hard Disable Extensions
(11) Hard Enable Extensions
(12) Automagically Disable Extensions
(13) Edit Pollen
(14) Install Crouton
(15) Start Crouton
(16) Enable dev_boot_usb
(17) Disable dev_boot_usb
(18) Set mushm password
(19) Remove mushm password
(20) Reboot (wait 5s)
(21) Install Gentoo Bootstrap (dev_install)
(22) [EXPERIMENTAL] Update ChromeOS
(23) [EXPERIMENTAL] Update Emergency Backup
(24) [EXPERIMENTAL] Restore Emergency Backup Backup
(25) [EXPERIMENTAL] Install Chromebrew
(26) [EXPERIMENTAL] Firmware Utility
(27) Check for updates Murkmod
(28) Check for updates MushM
EOF
        
        swallow_stdin
        read -r -p "> (1-29): " choice
        case "$choice" in
        1) runjob doas bash ;;
        2) runjob doas "cd /home/chronos; sudo -i -u chronos" ;;
        3) runjob /usr/bin/crosh.old ;;
        4) runjob show_plugins ;;
        5) runjob install_plugins ;;
        6) runjob uninstall_plugins ;;
        7) runjob powerwash ;;
        8) runjob revert ;;
        9) runjob softdisableext ;;
        10) runjob harddisableext ;;
        11) runjob hardenableext ;;
        12) runjob autodisableexts ;;
        13) runjob edit_pollen ;;
        14) runjob install_crouton ;;
        15) runjob run_crouton ;;
        16) runjob enable_dev_boot_usb ;;
        17) runjob disable_dev_boot_usb ;;
        18) runjob set_passwd ;;
        19) runjob remove_passwd ;;
        20) runjob reboot ;;
        21) runjob attempt_dev_install ;;
        22) runjob attempt_chromeos_update ;;
        23) runjob attempt_backup_update ;;
        24) runjob attempt_restore_backup_backup ;;
        25) runjob attempt_chromebrew_install ;;
        26) runjob run_firmware_util ;;
        27) runjob do_updates && exit 0 ;;
        28) runjob do_mushm_update ;;
        29) runjob do_dev_updates && exit 0 ;;
        101) runjob hard_disable_nokill ;;
        111) runjob hard_enable_nokill ;;
        112) runjob ext_purge ;;
        113) runjob list_plugins ;;
        114) runjob install_plugin_legacy ;;
        115) runjob uninstall_plugin_legacy ;;
        201) runjob api_read_file ;;
        202) runjob api_write_file ;;
        203) runjob api_append_file ;;
        204) runjob api_touch_file ;;
        205) runjob api_create_dir ;;
        206) runjob api_rm_file ;;
        207) runjob api_rm_dir ;;
        208) runjob api_ls_dir ;;
        209) runjob api_cd ;;
    
        *) echo && echo "Invalid option, dipshit." && echo ;;
        esac
    done
}

api_read_file() {
    echo "file to read?"
    read -r filename
    local contents=$( base64 $filename )
    echo "start content: $contents end content"
}

api_write_file() {
    echo "file to write to?"
    read -r filename
    echo "base64 contents?"
    read -r contents
    base64 -d <<< "$contents" > $filename
}

api_append_file() {
    echo "file to write to?"
    read -r filename
    echo "base64 contents to append?"
    read -r contents
    base64 -d <<< "$contents" >> $filename
}

api_touch_file() {
    echo "filename?"
    read -r filename
    touch $filename
}

api_create_dir() {
    echo "dirname?"
    read -r dirname
    mkdir -p $dirname
}

api_rm_file() {
    echo "filename?"
    read -r filename
    rm -f $filename
}

api_rm_dir() {
    echo "dirname?"
    read -r dirname
    rm -Rf $dirname
}

api_ls_dir() {
    echo "dirname? (or . for current dir)"
    read -r dirname
    ls $dirname
}

api_cd() {
    echo "dir?"
    read -r dirname
    cd $dirname
}

install_plugin_legacy() {
  local raw_url="https://github.com/Star-destroyer12/Murk-mod-plugins/tree/main/plugins"

  echo "Find a plugin you want to install here: "
  echo "  https://github.com/rainestorme/murkmod/tree/main/plugins"
  echo "Enter the name of a plugin (including the .sh) to install it (or q to quit):"
  read -r plugin_name

  local plugin_url="$raw_url/$plugin_name"
  local plugin_info=$(curl -s $plugin_url)

  if [[ $plugin_info == *"Not Found"* ]]; then
    echo "Plugin not found"
  else      
    echo "Installing..."
    doas "pushd /mnt/stateful_partition/murkmod/plugins && curl https://raw.githubusercontent.com/Star-destroyer12/Murk-mod-plugins/refs/heads/main/plugins/$plugin_name -O && popd" > /dev/null
    echo "Installed $plugin_name"
  fi
}

uninstall_plugin_legacy() {
  local raw_url="https://github.com/Star-destroyer12/Murk-mod-plugins/tree/main/plugins"
  echo "Enter the name of a plugin (including the .sh) to uninstall it (or q to quit):"
  read -r plugin_name
  doas "rm -rf /mnt/stateful_partition/murkmod/plugins/$plugin_name"
}

reboot() {
doas "reboot"
}

list_plugins() {
    local plugins_dir="/mnt/stateful_partition/murkmod/plugins"
    local plugin_files=()
    local plugin_info=()

    # Ensure the plugins directory exists
    if [[ ! -d "$plugins_dir" ]]; then
        echo "Plugins directory not found. Creating: $plugins_dir"
        if ! mkdir -p "$plugins_dir"; then
            echo "Error: Could not create plugins directory." >&2
            return 1
        fi
    fi

    # Find all .sh plugin files
    while IFS= read -r -d '' file; do
        plugin_files+=("$file")
    done < <(find "$plugins_dir" -type f -name "*.sh" -print0)

    # Process each plugin file
    for plugin_script in "${plugin_files[@]}"; do
        # Extract metadata
        local PLUGIN_NAME
        local PLUGIN_FUNCTION
        local PLUGIN_DESCRIPTION
        local PLUGIN_AUTHOR
        local PLUGIN_VERSION

        PLUGIN_NAME=$(grep -oP 'PLUGIN_NAME="\K[^"]+' "$plugin_script")
        PLUGIN_FUNCTION=$(grep -oP 'PLUGIN_FUNCTION="\K[^"]+' "$plugin_script")
        PLUGIN_DESCRIPTION=$(grep -oP 'PLUGIN_DESCRIPTION="\K[^"]+' "$plugin_script")
        PLUGIN_AUTHOR=$(grep -oP 'PLUGIN_AUTHOR="\K[^"]+' "$plugin_script")
        PLUGIN_VERSION=$(grep -oP 'PLUGIN_VERSION="\K[^"]+' "$plugin_script")

        # Only include plugins that have 'menu_plugin' in them
        if grep -q "menu_plugin" "$plugin_script"; then
            # Check required fields are not empty
            if [[ -n "$PLUGIN_FUNCTION" && -n "$PLUGIN_NAME" ]]; then
                plugin_info+=("${PLUGIN_FUNCTION},${PLUGIN_NAME},${PLUGIN_DESCRIPTION},${PLUGIN_AUTHOR},${PLUGIN_VERSION}")
            fi
        fi
    done

    # Format output
    if [[ ${#plugin_info[@]} -eq 0 ]]; then
        echo "No valid plugins found."
        return 0
    fi

    local output=""
    for info in "${plugin_info[@]}"; do
        output+="[][]$info"
    done

    echo "$output"
}


do_dev_updates() {
    echo "Welcome to the secret murkmod developer update menu!"
    echo "This utility allows you to install murkmod from a specific branch on the git repo."
    echo "If you were trying to update murkmod normally, then don't panic! Just enter 'main' at the prompt and everything will work normally."
    read -p "> (branch name, eg. main): " branch
    doas "MURKMOD_BRANCH=$branch bash <(curl -SLk https://raw.githubusercontent.com/rainestorme/murkmod/main/murkmod.sh)"
    exit
}

disable_ext() {
    local extid="$1"
    echo "$extid" | grep -qE '^[a-z]{32}$' && chmod 000 "/home/chronos/user/Extensions/$extid" && kill -9 $(pgrep -f "\-\-extension\-process") || "Extension ID $extid is invalid."
}

disable_ext_nokill() {
    local extid="$1"
    echo "$extid" | grep -qE '^[a-z]{32}$' && chmod 000 "/home/chronos/user/Extensions/$extid" || "Extension ID $extid is invalid."
}

enable_ext_nokill() {
    local extid="$1"
    echo "$extid" | grep -qE '^[a-z]{32}$' && chmod 777 "/home/chronos/user/Extensions/$extid" || "Invalid extension id."
}

ext_purge() {
    kill -9 $(pgrep -f "\-\-extension\-process")
}

hard_disable_nokill() {
    read -r -p "Enter extension ID > " extid
    disable_ext_nokill $extid
}

hard_enable_nokill() {
    read -r -p "Enter extension ID > " extid
    enable_ext_nokill $extid
}

autodisableexts() {
    echo "Disabling extensions..."
    disable_ext_nokill "haldlgldplgnggkjaafhelgiaglafanh" # GoGuardian
    disable_ext_nokill "dikiaagfielfbnbbopidjjagldjopbpa" # Clever Plus
    disable_ext_nokill "cgbbbjmgdpnifijconhamggjehlamcif" # Gopher Buddy
    disable_ext_nokill "inoeonmfapjbbkmdafoankkfajkcphgd" # Read and Write for Google Chrome
    disable_ext_nokill "enfolipbjmnmleonhhebhalojdpcpdoo" # Screenshot reader
    disable_ext_nokill "joflmkccibkooplaeoinecjbmdebglab" # Securly
    disable_ext_nokill "iheobagjkfklnlikgihanlhcddjoihkg" # Securly again
    disable_ext_nokill "adkcpkpghahmbopkjchobieckeoaoeem" # LightSpeed
    disable_ext_nokill "jcdhmojfecjfmbdpchihbeilohgnbdci" # Cisco Umbrella
    disable_ext_nokill "jdogphakondfdmcanpapfahkdomaicfa" # ContentKeeper Authenticator
    disable_ext_nokill "aceopacgaepdcelohobicpffbbejnfac" # Hapara
    disable_ext_nokill "kmffehbidlalibfeklaefnckpidbodff" # iBoss
    disable_ext_nokill "jaoebcikabjppaclpgbodmmnfjihdngk" # LightSpeed Classroom
    disable_ext_nokill "ghlpmldmjjhmdgmneoaibbegkjjbonbk" # Blocksi
    disable_ext_nokill "ddfbkhpmcdbciejenfcolaaiebnjcbfc" # Linewize
    disable_ext_nokill "jfbecfmiegcjddenjhlbhlikcbfmnafd" # Securly Classroom
    disable_ext_nokill "jjpmjccpemllnmgiaojaocgnakpmfgjg" # Impero
    disable_ext_nokill "feepmdlmhplaojabeoecaobfmibooaid" # OrbitNote
    disable_ext_nokill "dmhpekdihnngbkinliefnclgmgkpjeoo" # GoGuardian License
    disable_ext_nokill "modkadcjnbamppdpdkfoackjnhnfiogi" # MyMPS Chrome SSO
    ext_purge
    echo "Done."
}

set_passwd() {
  echo "Enter a new password to use for mushm. This will be required to perform any future administrative actions, so make sure you write it down somewhere!"
  read -r -p " > " newpassword
  doas "touch /mnt/stateful_partition/murkmod/mushM_password"
  doas "echo '$newpassword'> /mnt/stateful_partition/murkmod/mushM_password"
}

remove_passwd() {
  echo "Removing password from mushm..."
  doas "rm -f /mnt/stateful_partition/murkmod/mushM_password"
}

prompt_passwd() {
  echo "Enter your password:"
  read -r -p " > " password
  stored_password=$(cat /mnt/stateful_partition/murkmod/mushM_password)
  
  if [ "$password" == "$stored_password" ]; then
    main
    return
  else
    echo "Incorrect password."
    read -r -p "Press enter to continue." throwaway
  fi
}

disable_dev_boot_usb() {
  echo "Disabling dev_boot_usb"
  sed -i 's/\(dev_boot_usb=\).*/\10/' /usr/bin/crossystem
}

enable_dev_boot_usb() {
  echo "Enabling dev_boot_usb"
  sed -i 's/\(dev_boot_usb=\).*/\11/' /usr/bin/crossystem
}



do_updates() {
    doas "bash <(curl -SLk https://raw.githubusercontent.com/rainestorme/murkmod/main/murkmod.sh)"
    exit
}

do_mushm_update() {
    doas "bash <(curl -SLk https://raw.githubusercontent.com/Star-destroyer12/Murk-mod-plugins/main/installer.sh)"
    exit
}

show_plugins() {
    local plugins_dir="/mnt/stateful_partition/murkmod/plugins"
    local plugin_files=()
    local plugin_info=()
    local plugin_map=()

    [[ -d "$plugins_dir" ]] || { echo "Plugins directory does not exist."; return 1; }

    # Collect plugin files
    while IFS= read -r -d '' file; do
        plugin_files+=("$file")
    done < <(find "$plugins_dir" -type f -name "*.sh" -print0)

    # Read metadata for each plugin
    for plugin_script in "${plugin_files[@]}"; do
        # Only read first 200 lines
        mapfile -t meta < <(head -n 200 "$plugin_script" | sed 's/\r$//')

        local name="<no name>"
        local func="<no function>"
        local author="<no author>"
        local ver="<no version>"
        local menu_marker=0

        for line in "${meta[@]}"; do
            [[ "$line" =~ ^[[:space:]]*#?[[:space:]]*menu_plugin[[:space:]]*$ ]] && menu_marker=1
            [[ "$line" =~ ^[[:space:]]*PLUGIN_NAME[[:space:]]*=[[:space:]]*(.*)$ ]] && name="${BASH_REMATCH[1]//\"/}" && name="${name//\'/}"
            [[ "$line" =~ ^[[:space:]]*PLUGIN_FUNCTION[[:space:]]*=[[:space:]]*(.*)$ ]] && func="${BASH_REMATCH[1]//\"/}" && func="${func//\'/}"
            [[ "$line" =~ ^[[:space:]]*PLUGIN_AUTHOR[[:space:]]*=[[:space:]]*(.*)$ ]] && author="${BASH_REMATCH[1]//\"/}" && author="${author//\'/}"
            [[ "$line" =~ ^[[:space:]]*PLUGIN_VERSION[[:space:]]*=[[:space:]]*(.*)$ ]] && ver="${BASH_REMATCH[1]//\"/}" && ver="${ver//\'/}"
        done

        # Include plugin if it has the menu marker or a function
        if [[ $menu_marker -eq 1 || -n "$func" ]]; then
            plugin_info+=("$name|$func|$author|$ver")
            plugin_map+=("$plugin_script")
        fi
    done

    if [[ ${#plugin_info[@]} -eq 0 ]]; then
        echo "No plugins found."
        return 0
    fi

    # Print header
    printf "# %-25s %-35s %-20s %-10s\n" "Name" "Function" "Author" "Version"
    printf -- "------------------------------------------------------------------------------------------------------\n"

    # Print each plugin
    for i in "${!plugin_info[@]}"; do
        IFS='|' read -r name func author ver <<< "${plugin_info[$i]}"
        printf "%-3s %-25s %-35s %-20s %-10s\n" "$((i+1))" "$name" "$func" "$author" "$ver"
    done

    # Prompt user
    read -p "> Select a plugin (or q to quit): " selection
    selection="${selection//$'\r'/}"

    [[ "$selection" == "q" ]] && return 0

    if ! [[ "$selection" =~ ^[1-9][0-9]*$ ]] || (( selection < 1 || selection > ${#plugin_info[@]} )); then
        echo "Invalid selection."
        return 1
    fi

    local selected_file="${plugin_map[$((selection-1))]}"

    # Run plugin directly (original method)
    bash <(cat "$selected_file")
}

install_plugins() {
    clear
    echo "Fetching plugin information..."
    json=$(curl -s "https://api.github.com/repos/Star-destroyer12/Murk-mod-plugins/contents/plugins")
    file_contents=()
    download_urls=()

    for entry in $(echo "$json" | jq -c '.[]'); do
        if [[ $(echo "$entry" | jq -r '.type') == "file" ]]; then
            download_url=$(echo "$entry" | jq -r '.download_url')
            file_contents+=("$(curl -s "$download_url")")
            download_urls+=("$download_url")
        fi
    done

    plugin_info=()
    for content in "${file_contents[@]}"; do
        tmp_file=$(mktemp)
        echo "$content" > "$tmp_file"

        PLUGIN_NAME=$(grep -o 'PLUGIN_NAME=.*' "$tmp_file" | cut -d= -f2-)
        PLUGIN_FUNCTION=$(grep -o 'PLUGIN_FUNCTION=.*' "$tmp_file" | cut -d= -f2-)
        PLUGIN_DESCRIPTION=$(grep -o 'PLUGIN_DESCRIPTION=.*' "$tmp_file" | cut -d= -f2-)
        PLUGIN_AUTHOR=$(grep -o 'PLUGIN_AUTHOR=.*' "$tmp_file" | cut -d= -f2-)
        PLUGIN_VERSION=$(grep -o 'PLUGIN_VERSION=.*' "$tmp_file" | cut -d= -f2-)

        PLUGIN_NAME=${PLUGIN_NAME:1:-1}
        PLUGIN_FUNCTION=${PLUGIN_FUNCTION:1:-1}
        PLUGIN_DESCRIPTION=${PLUGIN_DESCRIPTION:1:-1}
        PLUGIN_AUTHOR=${PLUGIN_AUTHOR:1:-1}

        plugin_info+=(" $PLUGIN_NAME (version $PLUGIN_VERSION by $PLUGIN_AUTHOR) \n       $PLUGIN_DESCRIPTION")

        rm "$tmp_file"
    done

    clear
    selected_option=0

    while true; do
        for i in "${!plugin_info[@]}"; do
            if [ $i -eq $selected_option ]; then
                printf " -> "
            else
                printf "    "
            fi
            printf "${plugin_info[$i]}"
            filename=$(echo "${download_urls[$i]}" | rev | cut -d/ -f1 | rev)
            if [ -f "/mnt/stateful_partition/murkmod/plugins/$filename" ]; then
                echo " (installed)"
            else
                echo
            fi
        done

        read -s -n 1 key

        case "$key" in
            "q") break ;;
            "A") ((selected_option--)) ;;
            "B") ((selected_option++)) ;;
            "") clear
                echo "Using URL: ${download_urls[$selected_option]}"
                echo "Installing plugin..."
                doas "mkdir -p /mnt/stateful_partition/murkmod/plugins && pushd /mnt/stateful_partition/murkmod/plugins && curl -fsO ${download_urls[$selected_option]} && popd" >/dev/null
                echo "Installed plugin successfully!"
                ;;
        esac

        ((selected_option = selected_option < 0 ? 0 : selected_option))
        ((selected_option = selected_option >= ${#plugin_info[@]} ? ${#plugin_info[@]} - 1 : selected_option))

        clear
        echo "Available plugins (press q to exit):"
    done
}



uninstall_plugins() {
    clear
    
    plugins_dir="/mnt/stateful_partition/murkmod/plugins"
    plugin_files=()

    while IFS= read -r -d '' file; do
        plugin_files+=("$file")
    done < <(find "$plugins_dir" -type f -name "*.sh" -print0)

    plugin_info=()
    for file in "${plugin_files[@]}"; do
        plugin_script=$file
        PLUGIN_NAME=$(grep -o 'PLUGIN_NAME=.*' "$plugin_script" | cut -d= -f2-)
        PLUGIN_FUNCTION=$(grep -o 'PLUGIN_FUNCTION=.*' "$plugin_script" | cut -d= -f2-)
        PLUGIN_DESCRIPTION=$(grep -o 'PLUGIN_DESCRIPTION=.*' "$plugin_script" | cut -d= -f2-)
        PLUGIN_AUTHOR=$(grep -o 'PLUGIN_AUTHOR=.*' "$plugin_script" | cut -d= -f2-)
        PLUGIN_VERSION=$(grep -o 'PLUGIN_VERSION=.*' "$plugin_script" | cut -d= -f2-)
        PLUGIN_NAME=${PLUGIN_NAME:1:-1}
        PLUGIN_FUNCTION=${PLUGIN_FUNCTION:1:-1}
        PLUGIN_DESCRIPTION=${PLUGIN_DESCRIPTION:1:-1}
        PLUGIN_AUTHOR=${PLUGIN_AUTHOR:1:-1}
        plugin_info+=("$PLUGIN_NAME (version $PLUGIN_VERSION by $PLUGIN_AUTHOR)")
    done

    if [ ${#plugin_info[@]} -eq 0 ]; then
        echo "No plugins installed."
        read -r -p "Press enter to continue." throwaway
        return
    fi

    while true; do
        echo "Installed plugins:"
        for i in "${!plugin_info[@]}"; do
            echo "$(($i+1)). ${plugin_info[$i]}"
        done
        echo "0. Exit back to mushm"
        read -r -p "Enter a number to uninstall a plugin, or 0 to exit: " choice

        if [ "$choice" -eq 0 ]; then
            clear
            return
        fi

        index=$(($choice-1))

        if [ "$index" -lt 0 ] || [ "$index" -ge ${#plugin_info[@]} ]; then
            echo "Invalid choice."
            continue
        fi

        plugin_file="${plugin_files[$index]}"
        PLUGIN_NAME=$(grep -o 'PLUGIN_NAME=".*"' "$plugin_file" | cut -d= -f2-)
        PLUGIN_FUNCTION=$(grep -o 'PLUGIN_FUNCTION=".*"' "$plugin_file" | cut -d= -f2-)
        PLUGIN_DESCRIPTION=$(grep -o 'PLUGIN_DESCRIPTION=".*"' "$plugin_file" | cut -d= -f2-)
        PLUGIN_AUTHOR=$(grep -o 'PLUGIN_AUTHOR=".*"' "$plugin_file" | cut -d= -f2-)
        PLUGIN_VERSION=$(grep -o 'PLUGIN_VERSION=".*"' "$plugin_file" | cut -d= -f2-)
        # remove quotes
        PLUGIN_NAME=${PLUGIN_NAME:1:-1}
        PLUGIN_FUNCTION=${PLUGIN_FUNCTION:1:-1}
        PLUGIN_DESCRIPTION=${PLUGIN_DESCRIPTION:1:-1}
        PLUGIN_AUTHOR=${PLUGIN_AUTHOR:1:-1}

        plugin_name="$PLUGIN_NAME (version $PLUGIN_VERSION by $PLUGIN_AUTHOR)"

        read -r -p "Are you sure you want to uninstall $plugin_name? [y/n] " confirm
        if [ "$confirm" == "y" ]; then
            doas rm "$plugin_file"
            echo "$plugin_name uninstalled."
            unset plugin_info[$index]
            plugin_info=("${plugin_info[@]}")
        fi
    done
}

powerwash() {
    echo "Are you sure you wanna powerwash? This will remove all user accounts and data, but won't remove fakemurk."
    sleep 2
    echo "(Press enter to continue, ctrl-c to cancel)"
    swallow_stdin
    read -r
    doas rm -f /stateful_unfucked
    doas reboot
    exit
}

revert() {
    echo "This option will re-enroll your chromebook and restore it to its exact state before fakemurk was run. This is useful if you need to quickly go back to normal."
    echo "This is *permanent*. You will not be able to fakemurk again unless you re-run everything from the beginning."
    echo "Are you sure - 100% sure - that you want to continue? (press enter to continue, ctrl-c to cancel)"
    swallow_stdin
    read -r
    
    printf "Setting kernel priority in 3 (this is your last chance to cancel)..."
    sleep 1
    printf "2..."
    sleep 1
    echo "1..."
    sleep 1
    
    echo "Setting kernel priority"

    DST=$(get_largest_cros_blockdev)

    if doas "((\$(cgpt show -n \"$DST\" -i 2 -P) > \$(cgpt show -n \"$DST\" -i 4 -P)))"; then
        doas cgpt add "$DST" -i 2 -P 0
        doas cgpt add "$DST" -i 4 -P 1
    else
        doas cgpt add "$DST" -i 4 -P 0
        doas cgpt add "$DST" -i 2 -P 1
    fi
    
    echo "Setting vpd..."
    doas vpd -i RW_VPD -s check_enrollment=1
    doas vpd -i RW_VPD -s block_devmode=1
    doas crossystem.old block_devmode=1
    
    echo "Setting stateful unfuck flag..."
    rm -f /stateful_unfucked

    echo "Done. Press enter to reboot"
    swallow_stdin
    read -r
    echo "Bye!"
    sleep 2
    doas reboot
    sleep 1000
    echo "Your chromebook should have rebooted by now. If your chromebook doesn't reboot in the next couple of seconds, press Esc+Refresh to do it manually."
}

harddisableext() { # calling it "hard disable" because it only reenables when you press
    read -r -p "Enter extension ID > " extid
    echo "$extid" | grep -qE '^[a-z]{32}$' && chmod 000 "/home/chronos/user/Extensions/$extid" && kill -9 $(pgrep -f "\-\-extension\-process") || "Invalid extension id."
}

hardenableext() {
    read -r -p "Enter extension ID > " extid
    echo "$extid" | grep -qE '^[a-z]{32}$' && chmod 777 "/home/chronos/user/Extensions/$extid" && kill -9 $(pgrep -f "\-\-extension\-process") || "Invalid extension id."
}

softdisableext() {
    echo "Extensions will stay disabled until you press Ctrl+c or close this tab"
    while true; do
        kill -9 $(pgrep -f "\-\-extension\-process") 2>/dev/null
        sleep 0.5
    done
}

# https://chromium.googlesource.com/chromiumos/docs/+/master/lsb-release.md
lsbval() {
  local key="$1"
  local lsbfile="${2:-/etc/lsb-release}"

  if ! echo "${key}" | grep -Eq '^[a-zA-Z0-9_]+$'; then
    return 1
  fi

  sed -E -n -e \
    "/^[[:space:]]*${key}[[:space:]]*=/{
      s:^[^=]+=[[:space:]]*::
      s:[[:space:]]+$::
      p
    }" "${lsbfile}"
}


install_crouton() {
    # check if crouuton is already installed. if so, prompt the user to delete their old chroot
    if [ -f /mnt/stateful_partition/crouton_installed ] ; then
        read -p "Crouton is already installed. Would you like to delete your old chroot and create a new one? (y/N) " yn
        case $yn in
            [yY] ) doas "rm -rf /mnt/stateful_partition/crouton/chroots && rm -f /mnt/stateful_partition/crouton_installed";;
            [nN] ) return;;
            * ) return;;
        esac
    fi
    echo "Installing Crouton..."
    # if this is before v107, then we don't want to use the silence branch - audio is still supported
    local local_version=$(lsbval GOOGLE_RELEASE)
    if (( ${local_version%%\.*} <= 107 )); then
        doas "bash <(curl -SLk https://git.io/JZEs0) -r bullseye -t xfce"
    else
        # theoretically we could copy or link the includes for cras, but im not entirely sure how to do that
        # CROUTON_BRANCH=longliveaudiotools supports audio at the versions we're looking at, but it's experimental and tends to be broken
        # ig we can prompt the user?
        echo "Your version of ChromeOS is too recent to support the current main branch of Crouton. You can either install Crouton without audio support, or install the experimental audio branch. Which would you like to do?"
        echo "1. Install without audio support"
        echo "2. Install with experimental audio support (may be extremely broken)"
        read -r -p "> (1-2): " choice
        if [ "$choice" == "1" ]; then
            doas "CROUTON_BRANCH=silence bash <(curl -SLk https://git.io/JZEs0) -r bullseye -t xfce"
        elif [ "$choice" == "2" ]; then
            doas "CROUTON_BRANCH=longliveaudiotools bash <(curl -SLk https://git.io/JZEs0) -r bullseye -t xfce"
        else
            echo "Invalid option, defaulting to silence branch"
            doas "CROUTON_BRANCH=silence bash <(curl -SLk https://git.io/JZEs0) -r bullseye -t xfce"
        fi
    fi
    doas "bash <(echo 'touch /mnt/stateful_partition/crouton_installed')" # idfk about the syntax but it seems to work so im not complaining
}

run_crouton() {
    if [ -f /mnt/stateful_partition/crouton_installed ] ; then
        echo "Use Crtl+Shift+Alt+Forward and Ctrl+Shift+Alt+Back to toggle between desktops"
        doas "startxfce4"
    else
        echo "Install Crouton first!"
        read -p "Press enter to continue."
    fi
}

get_booted_kernnum() {
    if doas "((\$(cgpt show -n \"$dst\" -i 2 -P) > \$(cgpt show -n \"$dst\" -i 4 -P)))"; then
        echo -n 2
    else
        echo -n 4
    fi
}

opposite_num() {
    if [ "$1" == "2" ]; then
        echo -n 4
    elif [ "$1" == "4" ]; then
        echo -n 2
    elif [ "$1" == "3" ]; then
        echo -n 5
    elif [ "$1" == "5" ]; then
        echo -n 3
    else
        return 1
    fi
}

attempt_chromeos_update(){
    read -p "Do you want to use the default ChromeOS bootsplash? [y/N] " use_orig_bootsplash
    case "$use_orig_bootsplash" in
        [yY][eE][sS]|[yY]) 
            USE_ORIG_SPLASH="1"
            ;;
        *)
            USE_ORIG_SPLASH="0"
            ;;
    esac
    local builds=$(curl https://chromiumdash.appspot.com/cros/fetch_serving_builds?deviceCategory=Chrome%20OS)
    local release_board=$(lsbval CHROMEOS_RELEASE_BOARD)
    local board=${release_board%%-*}
    local hwid=$(jq "(.builds.$board[] | keys)[0]" <<<"$builds")
    local hwid=${hwid:1:-1}
    local latest_milestone=$(jq "(.builds.$board[].$hwid.pushRecoveries | keys) | .[length - 1]" <<<"$builds")
    local remote_version=$(jq ".builds.$board[].$hwid[$latest_milestone].version" <<<"$builds")
    local remote_version=${remote_version:1:-1}
    local local_version=$(lsbval GOOGLE_RELEASE)

    if (( ${remote_version%%\.*} > ${local_version%%\.*} )); then        
        echo "Updating to ${remote_version}. THIS MAY DELETE ALL USER DATA! Press enter to confirm, Ctrl+C to cancel."
        read -r

        echo "Dumping emergency revert backup to stateful (this might take a while)..."
        echo "Finding correct partitions..."
        local dst=$(get_largest_cros_blockdev)
        local tgt_kern=$(opposite_num $(get_booted_kernnum))
        local tgt_root=$(( $tgt_kern + 1 ))

        local kerndev=${dst}p${tgt_kern}
        local rootdev=${dst}p${tgt_root}

        echo "Dumping kernel..."
        doas dd if=$kerndev of=/mnt/stateful_partition/murkmod/kern_backup.img bs=4M status=progress
        echo "Dumping rootfs..."
        doas dd if=$rootdev of=/mnt/stateful_partition/murkmod/root_backup.img bs=4M status=progress

        echo "Creating restore flag..."
        doas touch /mnt/stateful_partition/restore-emergency-backup
        doas chmod 777 /mnt/stateful_partition/restore-emergency-backup

        echo "Backups complete, actually updating now..."

        # read choice
        local reco_dl=$(jq ".builds.$board[].$hwid.pushRecoveries[$latest_milestone]" <<< "$builds")
        local tmpdir=/mnt/stateful_partition/update_tmp/
        doas mkdir $tmpdir
        echo "Downloading ${remote_version} from ${reco_dl}..."
        curl "${reco_dl:1:-1}" | doas "dd of=$tmpdir/image.zip status=progress"
        echo "Unzipping update binary..."
        cat $tmpdir/image.zip | gunzip | doas "dd of=$tmpdir/image.bin status=progress"
        doas rm -f $tmpdir/image.zip
        echo "Invoking image patcher..."
        if [ "$USE_ORIG_SPLASH" == 0 ]; then
            doas image_patcher.sh "$tmpdir/image.bin"
        else
            doas image_patcher.sh "$tmpdir/image.bin" cros
        fi
        

        local loop=$(doas losetup -f | tr -d '\r' | tail -1)
        doas losetup -P "$loop" "$tmpdir/image.bin"

        echo "Performing update..."
        printf "Overwriting partitions in 3 (this is your last chance to cancel)..."
        sleep 1
        printf "2..."
        sleep 1
        echo "1..."
        sleep 1
        echo "Installing kernel patch to ${kerndev}..."
        doas dd if="${loop}p4" of="$kerndev" status=progress
        echo "Installing root patch to ${rootdev}..."
        doas dd if="${loop}p3" of="$rootdev" status=progress
        echo "Setting kernel priority..."
        doas cgpt add "$dst" -i 4 -P 0
        doas cgpt add "$dst" -i 2 -P 0
        doas cgpt add "$dst" -i "$tgt_kern" -P 1

        echo "Setting crossystem and vpd block_devmode..."
        doas crossystem.old block_devmode=0
        doas vpd -i RW_VPD -s block_devmode=0

        echo "Cleaning up..."
        doas rm -Rf $tmpdir
    
        read -p "Done! Press enter to continue."
    else
        echo "Update not required."
        read -p "Press enter to continue."
    fi
}

attempt_backup_update(){
    local builds=$(curl https://chromiumdash.appspot.com/cros/fetch_serving_builds?deviceCategory=Chrome%20OS)
    local release_board=$(lsbval CHROMEOS_RELEASE_BOARD)
    local board=${release_board%%-*}
    local hwid=$(jq "(.builds.$board[] | keys)[0]" <<<"$builds")
    local hwid=${hwid:1:-1}
    local latest_milestone=$(jq "(.builds.$board[].$hwid.pushRecoveries | keys) | .[length - 1]" <<<"$builds")
    local remote_version=$(jq ".builds.$board[].$hwid[$latest_milestone].version" <<<"$builds")
    local remote_version=${remote_version:1:-1}

    read -p "Do you want to make a backup of your backup, just in case? (Y/n) " yn

    case $yn in 
        [yY] ) do_backup=true ;;
        [nN] ) do_backup=false ;;
        * ) do_backup=true ;;
    esac

    echo "Updating to ${remote_version}. THIS CAN POSSIBLY DAMAGE YOUR EMERGENCY BACKUP! Press enter to confirm, Ctrl+C to cancel."
    read -r

    echo "Finding correct partitions..."
    local dst=$(get_largest_cros_blockdev)
    local tgt_kern=$(opposite_num $(get_booted_kernnum))
    local tgt_root=$(( $tgt_kern + 1 ))

    local kerndev=${dst}p${tgt_kern}
    local rootdev=${dst}p${tgt_root}

    if [ "$do_backup" = true ] ; then
        echo "Dumping emergency revert backup to stateful (this might take a while)..."

        echo "Dumping kernel..."
        doas dd if=$kerndev of=/mnt/stateful_partition/murkmod/kern_backup.img bs=4M status=progress
        echo "Dumping rootfs..."
        doas dd if=$rootdev of=/mnt/stateful_partition/murkmod/root_backup.img bs=4M status=progress

        echo "Backups complete, actually updating now..."
    fi

    # read choice
    local reco_dl=$(jq ".builds.$board[].$hwid.pushRecoveries[$latest_milestone]" <<< "$builds")
    local tmpdir=/mnt/stateful_partition/update_tmp/
    doas mkdir $tmpdir
    echo "Downloading ${remote_version} from ${reco_dl}..."
    curl "${reco_dl:1:-1}" | doas "dd of=$tmpdir/image.zip status=progress"
    echo "Unzipping update binary..."
    cat $tmpdir/image.zip | gunzip | doas "dd of=$tmpdir/image.bin status=progress"
    doas rm -f $tmpdir/image.zip

    echo "Creating loop device..."
    local loop=$(doas losetup -f | tr -d '\r')
    doas losetup -P "$loop" "$tmpdir/image.bin"

    printf "Overwriting backup in 3 (this is your last chance to cancel)..."
    sleep 1
    printf "2..."
    sleep 1
    echo "1..."
    sleep 1
    echo "Performing update..."
    echo "Installing kernel patch to ${kerndev}..."
    doas dd if="${loop}p4" of="$kerndev" status=progress
    echo "Installing root patch to ${rootdev}..."
    doas dd if="${loop}p3" of="$rootdev" status=progress

    echo "Setting crossystem and vpd block_devmode..." # idrk why, but it can't hurt to be safe
    doas crossystem.old block_devmode=0
    doas vpd -i RW_VPD -s block_devmode=0

    echo "Cleaning up..."
    doas rm -Rf $tmpdir

    read -p "Done! Press enter to continue."
}

attempt_restore_backup_backup() {
    echo "Looking for backup files..."
    dst=$(get_largest_cros_blockdev)
    tgt_kern=$(opposite_num $(get_booted_kernnum))
    tgt_root=$(( $tgt_kern + 1 ))

    kerndev=${dst}p${tgt_kern}
    rootdev=${dst}p${tgt_root}

    if [ -f /mnt/stateful_partition/murkmod/kern_backup.img ] && [ -f /mnt/stateful_partition/murkmod/root_backup.img ]; then
        echo "Backup files found!"
        echo "Restoring kernel..."
        dd if=/mnt/stateful_partition/murkmod/kern_backup.img of=$kerndev bs=4M status=progress
        echo "Restoring rootfs..."
        dd if=/mnt/stateful_partition/murkmod/root_backup.img of=$rootdev bs=4M status=progress
        echo "Removing backup files..."
        rm /mnt/stateful_partition/murkmod/kern_backup.img
        rm /mnt/stateful_partition/murkmod/root_backup.img
        echo "Restored successfully!"
        read -p "Press enter to continue."
    else
        echo "Missing backup image, aborting!"
        read -p "Press enter to continue."
    fi
}

attempt_install_chromebrew() {
    doas 'sudo -i -u chronos curl -Ls git.io/vddgY | bash' # kinda works now with cros_debug
    read -p 'Press enter to exit'
}

attempt_dev_install() {
    doas 'dev_install'
}

edit_pollen() {
    mkdir -p /mnt/stateful_partition/murkmod/pollen
    if [ ! -f /mnt/stateful_partition/murkmod/pollen/policy.json ]; then
        echo "{}" > /mnt/stateful_partition/murkmod/pollen/policy.json
    fi
    edit /mnt/stateful_partition/murkmod/pollen/policy.json
    if touch /etc/opt/chrome/policies/managed/.murkmod_test 2>/dev/null; then
        rm -f /etc/opt/chrome/policies/managed/.murkmod_test
        cp /mnt/stateful_partition/murkmod/pollen/policy.json /etc/opt/chrome/policies/managed/policy.json
    else
        mkdir -p /tmp/overlay/etc/opt/chrome/policies/managed
        cp /mnt/stateful_partition/murkmod/pollen/policy.json /tmp/overlay/etc/opt/chrome/policies/managed/policy.json
    fi
}

run_firmware_util() {
    local tmp_dir="/tmp"
    local url="https://mrchromebox.tech/firmware-util.sh"
    local tmp_file
    local rc=0

    # create temp file
    tmp_file="$(mktemp "$tmp_dir/firmware-util.XXXXXX")" || {
        printf '%s\n' "Error: failed to create temporary file" >&2
        return 1
    }

    # ensure curl is available
    if ! command -v curl >/dev/null 2>&1; then
        printf '%s\n' "Error: curl is required but not found" >&2
        rm -f "$tmp_file"
        return 1
    fi

    # download script quietly
    if ! curl -fsSL -o "$tmp_file" "$url"; then
        printf '%s\n' "Error: failed to download $url" >&2
        rm -f "$tmp_file"
        return 1
    fi

    # make readable; do not attempt to change executable bits on target files
    chmod 0644 "$tmp_file" >/dev/null 2>&1 || true

    # choose runner and execute; forward any function args to the script
    if declare -F doas >/dev/null 2>&1; then
        # doas is a shell function (SSH wrapper). Pipe the script into it so remote executes from stdin.
        if ! cat "$tmp_file" | doas bash -s -- "$@"; then
            printf '%s\n' "Error: firmware utility failed when run via doas function" >&2
            rc=1
        fi
    elif command -v doas >/dev/null 2>&1; then
        # doas is an external command
        if ! doas bash "$tmp_file" -- "$@"; then
            printf '%s\n' "Error: firmware utility failed when run via doas command" >&2
            rc=1
        fi
    elif command -v sudo >/dev/null 2>&1; then
        # fallback to sudo
        if ! sudo bash "$tmp_file" -- "$@"; then
            printf '%s\n' "Error: firmware utility failed when run via sudo" >&2
            rc=1
        fi
    else
        printf '%s\n' "Error: neither doas (function or command) nor sudo are available" >&2
        rc=1
    fi

    rm -f "$tmp_file"
    return $rc
}


if [ "$0" = "$BASH_SOURCE" ]; then
    stty sane
    if [ -f /mnt/stateful_partition/murkmod/mushm_password ]; then
        locked_main
    else
        main
    fi
fi
