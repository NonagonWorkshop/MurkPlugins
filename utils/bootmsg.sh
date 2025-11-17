#!bin/bash
cat <<EOF >/usr/share/chromeos-assets/text/boot_messages/en/block_devmode_virtual.txt
Oh fuck - ChromeOS is trying to kill itself.
ChromeOS detected developer mode and is trying to disable it to
comply with FWMP. This is most likely a bug and should be reported to
the murkmod GitHub Issues page.
EOF
cat <<EOF >/usr/share/chromeos-assets/text/boot_messages/en/self_repair.txt
Oops, Your System is fucking itself.
Hold tight while he tries to repair your system.
EOF
# auto repair message
cat <<EOF >/usr/share/chromeos-assets/text/boot_messages/en/anti_block_devmode_virtual.txt
Murkmod Auto-Repair
ChromeOS has tried to disable developer mode.
Murkmod is trying to repair your system.
Your system will boot in a few seconds...
EOF
