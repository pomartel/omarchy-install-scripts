#!/bin/bash

if [ "$INSTALL_TARGET" = "school" ]; then
  bat_brightness="50%"
  ac_brightness="100%"
else
  bat_brightness="25%"
  ac_brightness="70%"
fi

cat <<EOF | sudo tee "/etc/udev/rules.d/99-display-brightness.rules" >/dev/null
ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/brightnessctl -c backlight set $bat_brightness%"
ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/brightnessctl -c backlight set $ac_brightness%"
EOF

sudo udevadm control --reload-rules
