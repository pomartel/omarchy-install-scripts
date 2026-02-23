#!/bin/bash

set -euo pipefail

source "./set-target.sh"

./configs/install-ssh-key-from-1password.sh
./configs/install-yadm.sh

./INSTALL.sh
