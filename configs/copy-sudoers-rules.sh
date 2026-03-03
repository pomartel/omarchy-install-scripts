#!/bin/bash

SUDOERS_FILE="/etc/sudoers.d/custom-sudoers-rules"

printf 'Defaults timestamp_timeout=60\nDefaults !tty_tickets\n' | sudo tee "$SUDOERS_FILE" >/dev/null

sudo chmod 600 "$SUDOERS_FILE"
