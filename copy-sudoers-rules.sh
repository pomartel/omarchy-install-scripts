#!/usr/bin/env bash

SUDOERS_FILE="/etc/sudoers.d/sudo-po"

read -r -d '' SUDOERS_CONTENT <<'EOF'
Defaults timestamp_timeout=60
Defaults !tty_tickets
EOF

if [[ ! -f "$SUDOERS_FILE" ]] || ! sudo diff -q -Z "$SUDOERS_FILE" - <<<"$SUDOERS_CONTENT" >/dev/null; then
  printf '%s\n' "$SUDOERS_CONTENT" | sudo tee "$SUDOERS_FILE" >/dev/null
  sudo chmod 644 "$SUDOERS_FILE"
  echo "sudoers rules updated: $SUDOERS_FILE"
fi
