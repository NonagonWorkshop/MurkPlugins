#!bin/bash
doas() {
    ssh -t -p 1337 -i /rootkey -oStrictHostKeyChecking=no root@127.0.0.1 "$@"
}
doas "bash /mnt/stateful_partition/murkmod/mush/mushm.sh"
