#!/bin/bash

sudoers_file="/etc/sudoers.d/custom-sudoers-rules"

sudoers_rules='Defaults timestamp_timeout=60
Defaults !tty_tickets'

# A root-owned 0600 temporary file on the same filesystem permits atomic replacement.
# The dot in its name keeps sudo from loading it before validation.
sudoers_temp=$(sudo mktemp /etc/sudoers.d/.custom-sudoers-rules.XXXXXX)
if printf '%s\n' "$sudoers_rules" | sudo tee "$sudoers_temp" >/dev/null &&
  sudo visudo -cf "$sudoers_temp" &&
  sudo mv -fT -- "$sudoers_temp" "$sudoers_file"; then
  :
else
  sudoers_status=$?
  sudo rm -f -- "$sudoers_temp"
  return "$sudoers_status"
fi
