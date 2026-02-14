#!/bin/bash

# Check if hibernation is already configured
MKINITCPIO_CONF="/etc/mkinitcpio.conf.d/omarchy_resume.conf"
if [ -f "$MKINITCPIO_CONF" ] && grep -q "^HOOKS+=(resume)$" "$MKINITCPIO_CONF"; then
  exit 0
else
  omarchy-hibernation-setup

  sudo mkdir -p /etc/systemd/sleep.conf.d /etc/systemd/logind.conf.d

  read -r -d '' SLEEP_CONTENT <<'EOF'
[Sleep]
HibernateDelaySec=24h
HibernateOnACPower=no
EOF
  printf '%s\n' "$SLEEP_CONTENT" | sudo tee /etc/systemd/sleep.conf.d/hibernate.conf >/dev/null

  read -r -d '' LID_CONTENT <<'EOF'
[Login]
HandleLidSwitch=suspend-then-hibernate
EOF
  printf '%s\n' "$LID_CONTENT" | sudo tee /etc/systemd/logind.conf.d/lid.conf >/dev/null

fi
