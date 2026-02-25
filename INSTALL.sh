#!/bin/bash

set -euo pipefail

source ./set-target.sh

./packages/add-packages.sh

./configs/set-locale.sh
./configs/copy-sudoers-rules.sh
./configs/set-power-profile-rule.sh
./configs/clone-git-projects.sh
./configs/remove-default-apps.sh
./configs/set-default-font.sh
./configs/configure-hibernation.sh
./configs/create-dropbox-symlinks.sh

echo "All install scripts completed."
