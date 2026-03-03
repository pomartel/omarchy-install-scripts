#!/bin/bash

POWER_PROFILE_RULE_FILE="/etc/udev/rules.d/99-power-profile.rules"
read -r -d '' POWER_PROFILE_RULE_CONTENT <<'EOF'
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set balanced"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"
EOF
printf '%s\n' "$POWER_PROFILE_RULE_CONTENT" | sudo tee "$POWER_PROFILE_RULE_FILE" >/dev/null

brightness-display-bat-ac 30 90

# Switch power profile to power-saver on low battery
service=powerprofile-low-battery.timer
if ! systemctl is-active --user --quiet "$service"; then
  systemctl --user enable --now "$service"
  echo "Started $service"
fi
