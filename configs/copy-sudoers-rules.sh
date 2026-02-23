#!/bin/bash

SUDOERS_FILE="/etc/sudoers.d/custom-sudoers-rules"

read -r -d '' SUDOERS_CONTENT <<'EOF'
Defaults timestamp_timeout=60
Defaults !tty_tickets
EOF
printf '%s\n' "$SUDOERS_CONTENT" | sudo tee "$SUDOERS_FILE" >/dev/null
sudo chmod 600 "$SUDOERS_FILE"
