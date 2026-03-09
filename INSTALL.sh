#!/bin/bash

set -euo pipefail

start_time=$(date +%s.%N)

source ./set-target.sh

./packages/add-packages.sh

./configs/set-locale.sh
./configs/copy-sudoers-rules.sh
./configs/set-power-rules.sh
./configs/clone-git-projects.sh
./configs/remove-default-apps.sh
./configs/set-default-font.sh
./configs/configure-hibernation.sh
./configs/configure-bluetooth-wake.sh
./configs/configure-bluetooth-initramfs-unlock.sh
./configs/create-dropbox-symlinks.sh
./configs/disable-plocate.sh
./configs/disable-makima.sh

end_time=$(date +%s.%N)
elapsed_seconds=$(awk -v start="$start_time" -v end="$end_time" 'BEGIN { printf "%.1f", end - start }')

echo "All install scripts completed in ${elapsed_seconds}s"
