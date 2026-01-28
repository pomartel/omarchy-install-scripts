#!/usr/bin/env bash

RULE_FILE="/etc/udev/rules.d/99-power-profile.rules"

if [[ ! -f "$RULE_FILE" ]]; then
    sudo tee "$RULE_FILE" >/dev/null <<'EOF'
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set power-saver"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"
EOF

    sudo udevadm control --reload
    sudo udevadm trigger

    echo "udev power profile rule installed: $RULE_FILE"
fi
