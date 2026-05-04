#!/bin/bash

# Disable wake-on-USB by default for non-Intel USB devices, then explicitly re-enable
# it for Bluetooth HID-class adapters so Bluetooth keyboards can wake the machine.
printf '%s\n' 'ACTION=="add|change", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}!="8087", ATTR{power/wakeup}="disabled"' |
  sudo tee /etc/udev/rules.d/69-disable-non-bt-usb-wake.rules >/dev/null
printf '%s\n' 'ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="e0", ATTR{bDeviceSubClass}=="01", ATTR{bDeviceProtocol}=="01", ATTR{power/wakeup}="enabled"' |
  sudo tee /etc/udev/rules.d/70-bluetooth-keyboard-wake.rules >/dev/null

# Re-enable the ACPI CNVW wake source if firmware currently has it disabled.
if grep -qE '^CNVW[[:space:]].*\*disabled' /proc/acpi/wakeup; then
  printf '%s\n' CNVW | sudo tee /proc/acpi/wakeup >/dev/null 2>&1
fi

# Keep the USB controller itself wake-capable so the Bluetooth adapter can bubble up wake events.
if [[ -e /sys/bus/pci/devices/0000:00:14.0/power/wakeup ]]; then
  printf '%s\n' enabled | sudo tee /sys/bus/pci/devices/0000:00:14.0/power/wakeup >/dev/null
fi

# Some kernels expose the Bluetooth wake toggle at either parent level, so enable both when present.
for wake in /sys/class/bluetooth/hci0/device/{../,../../}power/wakeup; do
  [[ -e "$wake" ]] || continue
  printf '%s\n' enabled | sudo tee "$wake" >/dev/null
done
