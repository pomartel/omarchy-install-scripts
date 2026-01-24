#!/bin/bash

SRC="$HOME/.config/sudoers.d/sudo-po"
DST="/etc/sudoers.d/sudo-po"

if [[ ! -f "$SRC" ]]; then
    echo "Sudoers config $SRC not found; cannot copy file." >&2
    exit 1
fi

# If destination exists and contents are identical, do nothing
if sudo test -f "$DST" && sudo cmp -s "$SRC" "$DST"; then
    exit 0
fi

echo "Copying sudoers config (content changed or destination missing)..."
sudo cp "$SRC" "$DST"
sudo chmod 440 "$DST"
