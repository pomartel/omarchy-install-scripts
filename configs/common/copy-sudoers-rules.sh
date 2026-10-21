#!/bin/bash

sudoers_file="/etc/sudoers.d/custom-sudoers-rules"

sudoers_rules='Defaults timestamp_timeout=60
Defaults !tty_tickets'

printf '%s\n' "$sudoers_rules" | sudo tee "$sudoers_file" >/dev/null
sudo chmod 600 "$sudoers_file"
