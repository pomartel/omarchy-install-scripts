#!/bin/bash

set -euo pipefail

source "./set-target.sh"

./configs/new-install/install-ssh-key-from-1password.sh
./configs/new-install/install-yadm.sh

./INSTALL.sh
