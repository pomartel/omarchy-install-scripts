#!/bin/bash

printf '%s\n' 'ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="e0", ATTR{bDeviceSubClass}=="01", ATTR{bDeviceProtocol}=="01", ATTR{power/wakeup}="enabled"' | sudo tee /etc/udev/rules.d/70-bluetooth-keyboard-wake.rules >/dev/null

if awk '$1 == "CNVW" && $3 ~ /\*disabled/' /proc/acpi/wakeup >/dev/null 2>&1; then
  printf '%s\n' CNVW | sudo tee /proc/acpi/wakeup >/dev/null
fi

for wake in \
  "$(readlink -f /sys/class/bluetooth/hci0/device/../power/wakeup 2>/dev/null)" \
  "$(readlink -f /sys/class/bluetooth/hci0/device/../../power/wakeup 2>/dev/null)"
do
  if [[ -n "$wake" && -e "$wake" ]]; then
    printf '%s\n' enabled | sudo tee "$wake" >/dev/null
  fi
done
