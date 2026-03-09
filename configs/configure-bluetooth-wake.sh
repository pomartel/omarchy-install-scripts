#!/bin/bash

if [ "$INSTALL_TARGET" = "school" ]; then
  exit 0
fi

udev_rule_path="/etc/udev/rules.d/70-bluetooth-wake.rules"

sudo install -d /etc/udev/rules.d

udev_rule_contents=$(
  cat <<'EOF'
# Keep Bluetooth controllers wake-capable after boot and controller re-enumeration.
ACTION=="add", SUBSYSTEM=="pci", DRIVERS=="btintel_pcie", ATTR{power/wakeup}="enabled"
ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="btusb", TEST=="power/wakeup", ATTR{power/wakeup}="enabled"
EOF
)

printf '%s\n' "$udev_rule_contents" | sudo tee "$udev_rule_path" >/dev/null

shopt -s nullglob
for wake_file in /sys/class/bluetooth/hci*/device/power/wakeup; do
  if [[ $(<"$wake_file") != "enabled" ]]; then
    printf '%s\n' enabled | sudo tee "$wake_file" >/dev/null
  fi
done

if command -v bluetoothctl >/dev/null 2>&1 && systemctl is-active --quiet bluetooth.service; then
  mapfile -t paired_devices < <(bluetoothctl devices Paired 2>/dev/null | awk '{print $2}')

  for mac in "${paired_devices[@]}"; do
    [[ -n "$mac" ]] || continue

    info=$(bluetoothctl info "$mac" 2>/dev/null || true)
    if grep -Eq 'Icon: input-(keyboard|mouse)|UUID: Human Interface Device' <<<"$info" &&
      ! grep -q 'WakeAllowed: yes' <<<"$info"; then
      bluetoothctl --timeout 5 wake "$mac" on >/dev/null 2>&1 || true
    fi
  done
fi

sudo udevadm control --reload
