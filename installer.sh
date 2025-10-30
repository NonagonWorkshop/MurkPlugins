#!bin/bash

cd /
cd usr/bin
echo "Made By Rainstorm Modified by Star_destroyer11"
echo "Making backup"
touch cros-bak.sh
cat crosh > cros-bak.sh
sleep 1
echo "Getting MushM"
curl -O https://raw.githubusercontent.com/NonagonWorkshop/MurkPlugins/main/utils/mushm.sh
cat mushm.sh > crosh
cd /
sleep 1
echo "Making folders"
mkdir mnt/stateful_partition/murkmod
mkdir mnt/stateful_partition/murkmod/plugins
mkdir mnt/stateful_partition/murkmod/pollen
sleep 1
echo "Done, have fun"
