#!/bin/bash

printf '%s\n' 'SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set balanced"' 'SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"' | sudo tee "/etc/udev/rules.d/99-power-profile.rules" >/dev/null

brightness-display-bat-ac 25 100

# Switch power profile to power-saver on low battery
service=powerprofile-low-battery.timer
if ! systemctl is-active --user --quiet "$service"; then
  systemctl --user enable --now "$service"
  echo "Started $service"
fi

# Fix slow wake from suspend
sudo ln -s ~/.config/systemd/plocate-updatedb.service.d/ac-only.conf /etc/systemd/system/plocate-updatedb.service.d/ac-only.conf
