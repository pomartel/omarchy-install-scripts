#!/bin/bash

bluetooth_path=$(readlink -f /sys/class/bluetooth/hci0/device 2>/dev/null || true)

if [[ -z "$bluetooth_path" ]]; then
  echo "Bluetooth controller hci0 not found; skipping wake configuration."
else
  usb_path="$bluetooth_path"
  while [[ "$usb_path" != "/" && ! -f "$usb_path/idVendor" ]]; do
    usb_path=$(dirname "$usb_path")
  done

  if [[ ! -f "$usb_path/idVendor" || ! -f "$usb_path/idProduct" || ! -e "$usb_path/power/wakeup" ]]; then
    echo "Could not find the USB wake controls for Bluetooth controller hci0."
  else
    usb_vendor=$(<"$usb_path/idVendor")
    usb_product=$(<"$usb_path/idProduct")
    pci_path="$usb_path"

    while [[ "$pci_path" != "/" ]]; do
      if [[ -L "$pci_path/subsystem" && $(basename "$(readlink -f "$pci_path/subsystem")") == "pci" ]]; then
        break
      fi
      pci_path=$(dirname "$pci_path")
    done

    wake_rule=$(printf 'ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="%s", ATTR{idProduct}=="%s", ATTR{power/wakeup}="enabled"' "$usb_vendor" "$usb_product")

    if [[ "$pci_path" != "/" && -f "$pci_path/vendor" && -f "$pci_path/device" && -e "$pci_path/power/wakeup" ]]; then
      pci_vendor=$(<"$pci_path/vendor")
      pci_device=$(<"$pci_path/device")
      wake_rule+=$(printf '\nACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="%s", ATTR{device}=="%s", ATTR{power/wakeup}="enabled"' "$pci_vendor" "$pci_device")
    fi

    printf '%s\n' "$wake_rule" | sudo tee /etc/udev/rules.d/70-bluetooth-keyboard-wake.rules >/dev/null
    echo enabled | sudo tee "$usb_path/power/wakeup" >/dev/null

    if [[ "$pci_path" != "/" && -e "$pci_path/power/wakeup" ]]; then
      echo enabled | sudo tee "$pci_path/power/wakeup" >/dev/null
    fi

    sudo udevadm control --reload-rules
  fi
fi
