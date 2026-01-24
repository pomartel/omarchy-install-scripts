#!/bin/bash

# THIS SCRIPT MUST BE EXECUTED FIRST

REPO_URL="git@github.com:pomartel/config-files.git"

if ! command -v yadm >/dev/null 2>&1; then
    pacman -S --noconfirm yadm
fi

REPO_DIR="$HOME/.local/share/yadm/repo.git"

# Only clone if the repo directory doesn't already exist
echo "Cloning yadm repository: $REPO_URL"

yadm clone -f "$REPO_URL"

echo "Force-resetting work-tree (discarding local conflicting files)..."
yadm reset --hard

echo "Done. Local dotfiles now exactly match the yadm repo."

yadm alt
