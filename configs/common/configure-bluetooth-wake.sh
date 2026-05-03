#!/bin/bash

sudo rm -f /etc/udev/rules.d/71-disable-xhci-wake.rules

printf '%s\n' 'ACTION=="add|change", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}!="8087", ATTR{power/wakeup}="disabled"' |
  sudo tee /etc/udev/rules.d/69-disable-non-bt-usb-wake.rules >/dev/null
printf '%s\n' 'ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="e0", ATTR{bDeviceSubClass}=="01", ATTR{bDeviceProtocol}=="01", ATTR{power/wakeup}="enabled"' |
  sudo tee /etc/udev/rules.d/70-bluetooth-keyboard-wake.rules >/dev/null

if grep -qE '^CNVW[[:space:]].*\*disabled' /proc/acpi/wakeup; then
  printf '%s\n' CNVW | sudo tee /proc/acpi/wakeup >/dev/null 2>&1
fi

if [[ -e /sys/bus/pci/devices/0000:00:14.0/power/wakeup ]]; then
  printf '%s\n' enabled | sudo tee /sys/bus/pci/devices/0000:00:14.0/power/wakeup >/dev/null
fi

for wake in /sys/bus/usb/devices/3-*/power/wakeup; do
  [[ -e "$wake" ]] || continue
  [[ "$wake" == /sys/bus/usb/devices/3-6/power/wakeup ]] && continue
  printf '%s\n' disabled | sudo tee "$wake" >/dev/null
done

for wake in /sys/class/bluetooth/hci0/device/{../,../../}power/wakeup; do
  [[ -e "$wake" ]] || continue
  printf '%s\n' enabled | sudo tee "$wake" >/dev/null
done
