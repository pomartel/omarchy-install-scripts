#!/bin/bash

printf '%s\n' 'ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0xa876", ATTR{power/wakeup}="enabled"' | sudo tee "/etc/udev/rules.d/70-bluetooth-keyboard-wake.rules" >/dev/null

wake="/sys/devices/pci0000:00/0000:00:14.7/power/wakeup"
if [[ -e "$wake" ]]; then
  echo enabled | sudo tee "$wake" >/dev/null
fi
