#!/bin/bash

doas() {
    ssh -t -p 1337 -i /rootkey -oStrictHostKeyChecking=no root@127.0.0.1 "$@"
}

cd /
cd mnt/stateful_partition/
doas "sudo mkdir murkmod/mushm/"
cd murkmod/mushm
doas "curl -O https://raw.githubusercontent.com/NonagonWorkshop/MurkPlugins/main/utils/mushm.sh"
cd /

# Launch Mush
doas "exec bash mnt/stateful_partition/murkmod/mushm/mushm.sh"
