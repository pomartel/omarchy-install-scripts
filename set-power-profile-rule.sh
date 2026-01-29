#!/usr/bin/env bash

RULE_FILE="/etc/udev/rules.d/99-power-profile.rules"

read -r -d '' RULE_CONTENT <<'EOF'
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set power-saver"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"
EOF

if [[ ! -f "$RULE_FILE" ]] || ! sudo diff -q -Z "$RULE_FILE" - <<<"$RULE_CONTENT" >/dev/null; then
  printf '%s' "$RULE_CONTENT" | sudo tee "$RULE_FILE" >/dev/null

  sudo udevadm control --reload
  sudo udevadm trigger --subsystem-match=power_supply

  echo "udev power profile rule installed: $RULE_FILE"
fi
