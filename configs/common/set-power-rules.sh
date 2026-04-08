#!/bin/bash

sudo tee "/etc/udev/rules.d/99-power-profile.rules" >/dev/null <<EOF
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set balanced"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"
EOF

if [ "$INSTALL_TARGET" = "school" ]; then
  bat_brightness="50%"
  ac_brightness="100%"
else
  bat_brightness="25%"
  ac_brightness="80%"
fi

rule_file="/etc/udev/rules.d/99-display-brightness.rules"
cat <<EOF | sudo tee "$rule_file" >/dev/null
ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/brightnessctl -c backlight set $bat_brightness"
ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/brightnessctl -c backlight set $ac_brightness"
EOF

# Switch power profile to power-saver on low battery
service=powerprofile-low-battery.timer
if ! systemctl is-active --user --quiet "$service"; then
  systemctl --user enable --now "$service"
  echo "Started $service"
fi
