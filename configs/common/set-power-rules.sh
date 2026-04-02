#!/bin/bash

sudo tee "/etc/udev/rules.d/99-power-profile.rules" >/dev/null <<EOF
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set balanced"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"
EOF

brightness-display-bat-ac 25 70

# Switch power profile to power-saver on low battery
service=powerprofile-low-battery.timer
if ! systemctl is-active --user --quiet "$service"; then
  systemctl --user enable --now "$service"
  echo "Started $service"
fi
