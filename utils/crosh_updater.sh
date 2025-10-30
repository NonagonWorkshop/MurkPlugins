#!/bin/bash

cd /
cd mnt/stateful_partition/
mkdir murkmod/mushm/
curl -O https://raw.githubusercontent.com/NonagonWorkshop/MurkPlugins/main/utils/mushm.sh
cd /

# Launch Mush
exec bash mnt/stateful_partition/murkmod/mushm/mushm.sh
