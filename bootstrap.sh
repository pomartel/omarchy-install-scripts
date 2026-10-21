#!/bin/bash

source ./scripts/migrations.sh || exit
install_validate_hostname
# Assigned inside the trap before it is used.
# shellcheck disable=SC2154
trap 'status=$?; install_release_lock; exit "$status"' EXIT
install_acquire_lock

omarchy-pkg-add yadm

yadm clone -f "git@github.com:pomartel/config-files.git"

echo "Force-resetting work-tree (discarding local conflicting files)..."
yadm reset --hard

echo "Creating symlinks for alternate files"
yadm alt

echo "Decrypting secret files"
yadm decrypt

install_run --all
