#!/bin/bash

if [ "$INSTALL_TARGET" = "asus" ]; then
  bat_brightness="50%"
  ac_brightness="100%"
else
  bat_brightness="25%"
  ac_brightness="70%"
fi

brightness_rules=$(
  cat <<EOF
ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/brightnessctl -c backlight set $bat_brightness%"
ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/brightnessctl -c backlight set $ac_brightness%"
EOF
)

if ! cmp -s <(printf '%s\n' "$brightness_rules") /etc/udev/rules.d/99-display-brightness.rules; then
  printf '%s\n' "$brightness_rules" | sudo tee /etc/udev/rules.d/99-display-brightness.rules >/dev/null
  sudo udevadm control --reload-rules
fi
unset brightness_rules bat_brightness ac_brightness
