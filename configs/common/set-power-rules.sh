#!/bin/bash

cat <<EOF | sudo tee "/etc/udev/rules.d/99-power-profile.rules" >/dev/null
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/systemd-run --no-block --collect --unit=omarchy-power-profile-battery --property=After=power-profiles-daemon.service $HOME/bin/omarchy-powerprofiles-set battery"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/systemd-run --no-block --collect --unit=omarchy-power-profile-ac --property=After=power-profiles-daemon.service $HOME/bin/omarchy-powerprofiles-set ac"
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
ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/brightnessctl -c backlight set $bat_brightness%"
ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/brightnessctl -c backlight set $ac_brightness%"
EOF

# Reload udev rules
sudo udevadm control --reload-rules

# Switch power profile to power-saver on low battery
service=powerprofile-low-battery.timer
if ! systemctl is-active --user --quiet "$service"; then
  systemctl --user enable --now "$service"
  echo "Started $service"
fi
