#!/bin/bash

cd /usr/bin || exit

echo "Made By Rainstorm, Modified by Star_destroyer11"

echo "Making backup of crosh"
touch cros-bak.sh
cat crosh > cros-bak.sh

sleep 1

echo "Getting MushM"
curl -O https://raw.githubusercontent.com/NonagonWorkshop/MurkPlugins/main/utils/mushm.sh

echo "Replacing crosh with MushM"
cat mushm.sh > crosh

cd / || exit

sleep 1

echo "Making directories"
mkdir -p /mnt/stateful_partition/murkmod/plugins
mkdir -p /mnt/stateful_partition/murkmod/pollen

sleep 1

echo "Fixing UwU error message"
cat <<EOF > /usr/share/chromeos-assets/text/boot_messages/en/self_repair.txt
Oops, Your System is getting fucked. We don't know why.
Hold tight while we try to repair.
EOF

# Final message
sleep 1
echo "Done, have fun!"
