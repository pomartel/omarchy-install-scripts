#!/bin/bash
omarchy-pkg-add yadm

yadm clone -f "git@github.com:pomartel/config-files.git"

echo "Force-resetting work-tree (discarding local conflicting files)..."
yadm reset --hard

echo "Creating symlinks for alternate files"
yadm alt

echo "Decrypting secret files"
yadm decrypt
