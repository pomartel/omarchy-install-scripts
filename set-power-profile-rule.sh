#!/usr/bin/env bash

RULE_FILE="/etc/udev/rules.d/99-power-profile.rules"

read -r -d '' RULE_CONTENT <<'EOF'
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set power-saver"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"
EOF

printf '%s\n' "$RULE_CONTENT" | sudo tee "$RULE_FILE" >/dev/null
