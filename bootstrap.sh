#!/bin/bash

source ./scripts/runner.sh || exit
install_validate_hostname

# post_clone applies shared preferences, including TOML, immediately.
omarchy-pkg-add yadm python-tomlkit

yadm clone -f "git@github.com:pomartel/config-files.git"

echo "Force-resetting work-tree (discarding local conflicting files)..."
yadm reset --hard

echo "Creating symlinks for alternate files"
yadm alt

echo "Decrypting secret files"
yadm decrypt

install_run --all
