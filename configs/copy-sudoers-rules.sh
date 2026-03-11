#!/bin/bash

SUDOERS_FILE="/etc/sudoers.d/custom-sudoers-rules"

sudo tee "$SUDOERS_FILE" >/dev/null <<EOF
Defaults timestamp_timeout=60
Defaults !tty_tickets
EOF

sudo chmod 600 "$SUDOERS_FILE"
