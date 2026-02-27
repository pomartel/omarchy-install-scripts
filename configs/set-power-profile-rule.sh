#!/bin/bash

RULE_FILE="/etc/udev/rules.d/99-power-profile.rules"

read -r -d '' RULE_CONTENT <<'EOF'
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set balanced"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"
EOF

printf '%s\n' "$RULE_CONTENT" | sudo tee "$RULE_FILE" >/dev/null

# Monitor and adjust refresh rate when power profile changes
if ! systemctl is-active --user --quiet adjust-refresh-rate; then
  systemctl --user enable --now adjust-refresh-rate.service
  echo "Starting adjust-refresh-rate.service..."
fi

# Switch power profile to power-saver on low battery
if ! systemctl is-active --user --quiet switch-power-profile-on-low-battery.timer; then
  systemctl --user enable --now switch-power-profile-on-low-battery.timer
  echo "Starting switch-power-profile-on-low-battery.timer..."
fi
