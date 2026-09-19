#!/bin/bash

bluetooth_path=$(readlink -f /sys/class/bluetooth/hci0/device 2>/dev/null || true)

if [[ -z "$bluetooth_path" ]]; then
  echo "Bluetooth controller hci0 not found; skipping wake disable configuration."
else
  usb_path="$bluetooth_path"
  while [[ "$usb_path" != "/" && ! -f "$usb_path/idVendor" ]]; do
    usb_path=$(dirname "$usb_path")
  done

  pci_path="$bluetooth_path"
  while [[ "$pci_path" != "/" ]]; do
    if [[ -L "$pci_path/subsystem" && $(basename "$(readlink -f "$pci_path/subsystem")") == "pci" ]]; then
      break
    fi
    pci_path=$(dirname "$pci_path")
  done

  if [[ -f "$usb_path/idVendor" && -f "$usb_path/idProduct" && -e "$usb_path/power/wakeup" ]]; then
    usb_vendor=$(<"$usb_path/idVendor")
    usb_product=$(<"$usb_path/idProduct")
    wake_rule=$(printf 'ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="%s", ATTR{idProduct}=="%s", ATTR{power/wakeup}="disabled"' "$usb_vendor" "$usb_product")
  else
    wake_rule=""
  fi

  if [[ "$pci_path" != "/" && -f "$pci_path/vendor" && -f "$pci_path/device" && -e "$pci_path/power/wakeup" ]]; then
    pci_vendor=$(<"$pci_path/vendor")
    pci_device=$(<"$pci_path/device")
    [[ -n "$wake_rule" ]] && wake_rule+=$'\n'
    wake_rule+=$(printf 'ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="%s", ATTR{device}=="%s", ATTR{power/wakeup}="disabled"' "$pci_vendor" "$pci_device")
  fi

  if [[ -z "$wake_rule" ]]; then
    echo "Could not find wake controls for Bluetooth controller hci0."
  else
    printf '%s\n' "$wake_rule" | sudo tee /etc/udev/rules.d/70-bluetooth-keyboard-wake.rules >/dev/null
    if [[ -e "$usb_path/power/wakeup" ]]; then
      echo disabled | sudo tee "$usb_path/power/wakeup" >/dev/null
    fi

    if [[ "$pci_path" != "/" && -e "$pci_path/power/wakeup" ]]; then
      echo disabled | sudo tee "$pci_path/power/wakeup" >/dev/null
    fi

    sudo udevadm control --reload-rules
  fi
fi
