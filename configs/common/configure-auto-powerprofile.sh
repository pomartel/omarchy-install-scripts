#!/bin/bash

cat <<EOF | sudo tee "/etc/udev/rules.d/99-power-profile.rules" >/dev/null
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/systemd-run --no-block --collect --unit=omarchy-power-profile-battery --property=After=power-profiles-daemon.service $HOME/bin/omarchy-powerprofiles-set battery"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/systemd-run --no-block --collect --unit=omarchy-power-profile-ac --property=After=power-profiles-daemon.service $HOME/bin/omarchy-powerprofiles-set ac"
EOF

sudo udevadm control --reload-rules

# POWER_SAVER_BATTERY_TRESHOLD env variable is set in ~/.config/uwsm/env
# Switch power profile to power-saver on low battery
service=powerprofile-low-battery.timer
if ! systemctl is-active --user --quiet "$service"; then
  systemctl --user enable --now "$service"
  echo "Started $service"
fi
