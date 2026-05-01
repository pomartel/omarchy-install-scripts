#!/bin/bash

printf '%s\n' 'ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="e0", ATTR{bDeviceSubClass}=="01", ATTR{bDeviceProtocol}=="01", ATTR{power/wakeup}="enabled"' | sudo tee /etc/udev/rules.d/70-bluetooth-keyboard-wake.rules >/dev/null

if grep -qE '^CNVW[[:space:]].*\*disabled' /proc/acpi/wakeup; then
  printf '%s\n' CNVW | sudo tee /proc/acpi/wakeup >/dev/null 2>&1
fi

for wake in /sys/class/bluetooth/hci0/device/{../,../../}power/wakeup; do
  [[ -e "$wake" ]] || continue
  printf '%s\n' enabled | sudo tee "$wake" >/dev/null
done
