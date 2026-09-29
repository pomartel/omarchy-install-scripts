#!/bin/bash

sudoers_file="/etc/sudoers.d/custom-sudoers-rules"

sudoers_rules='Defaults timestamp_timeout=60
Defaults !tty_tickets'

if ! printf '%s\n' "$sudoers_rules" | sudo cmp -s - "$sudoers_file"; then
  printf '%s\n' "$sudoers_rules" | sudo tee "$sudoers_file" >/dev/null
fi

if [[ $(sudo stat -c '%a' "$sudoers_file") != 600 ]]; then
  sudo chmod 600 "$sudoers_file"
fi
unset sudoers_file sudoers_rules
