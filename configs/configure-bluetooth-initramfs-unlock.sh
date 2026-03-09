#!/bin/bash

set -euo pipefail

readonly hooks_path="/etc/mkinitcpio.conf.d/omarchy_hooks.conf"
readonly modules_path="/etc/mkinitcpio.conf.d/bluetooth_unlock_modules.conf"
readonly files_path="/etc/mkinitcpio.conf.d/bluetooth_unlock_files.conf"

add_unique() {
  local item=$1
  local -n items_ref=$2
  local existing

  for existing in "${items_ref[@]}"; do
    [[ $existing == "$item" ]] && return 0
  done

  items_ref+=("$item")
}

set_auto_enable() {
  if grep -Eq '^[[:space:]]*AutoEnable=true([[:space:]]|$)' /etc/bluetooth/main.conf; then
    return 0
  fi

  if grep -Eq '^[[:space:]]*#?[[:space:]]*AutoEnable=' /etc/bluetooth/main.conf; then
    sudo sed -i 's/^[[:space:]]*#\?[[:space:]]*AutoEnable=.*/AutoEnable=true/' /etc/bluetooth/main.conf
  else
    printf '\nAutoEnable=true\n' | sudo tee -a /etc/bluetooth/main.conf >/dev/null
  fi
}

update_hooks() {
  local hooks_line hooks_body hook
  local inserted=false
  local -a hooks=()
  local -a updated_hooks=()

  hooks_line=$(grep -E '^[[:space:]]*HOOKS=\(' "$hooks_path" | head -n 1 || true)
  if [[ -z $hooks_line ]]; then
    printf 'Error: could not find HOOKS=() in %s\n' "$hooks_path" >&2
    exit 1
  fi

  hooks_body=${hooks_line#*=}
  hooks_body=${hooks_body#\(}
  hooks_body=${hooks_body%\)}
  read -r -a hooks <<<"$hooks_body"

  for hook in "${hooks[@]}"; do
    case $hook in
      systemd | sd-encrypt)
        printf 'Error: mkinitcpio-bluetooth does not work with the systemd hook path.\n' >&2
        exit 1
        ;;
      bluetooth)
        inserted=true
        ;;
      encrypt)
        if [[ $inserted == false ]]; then
          updated_hooks+=(bluetooth)
          inserted=true
        fi
        updated_hooks+=("$hook")
        ;;
      *)
        updated_hooks+=("$hook")
        ;;
    esac
  done

  if [[ $inserted == false ]]; then
    updated_hooks+=(bluetooth)
  fi

  printf 'HOOKS=(%s)\n' "${updated_hooks[*]}" | sudo tee "$hooks_path" >/dev/null
}

detect_modules() {
  local module
  local -a modules=(uhid)

  while read -r module; do
    [[ -n $module ]] || continue
    add_unique "$module" modules
  done < <(lsmod | awk '/^(btintel_pcie|btintel|btbcm|btrtl|btmtk|ath3k|btusb|rfcomm|hidp)$/ {print $1}')

  if lspci -nn | grep -qiE 'Bluetooth .*Intel|Intel Corporation .*Bluetooth'; then
    add_unique btintel_pcie modules
  fi

  printf '%s\n' "${modules[@]}"
}

detect_firmware_files() {
  local firmware firmware_path
  local -a files=()

  while read -r firmware; do
    [[ -n $firmware ]] || continue
    firmware_path="/usr/lib/firmware/$firmware"

    if [[ -f $firmware_path ]]; then
      add_unique "$firmware_path" files
    elif [[ -f ${firmware_path}.zst ]]; then
      add_unique "${firmware_path}.zst" files
    fi
  done < <(sudo journalctl -b -k 2>/dev/null | sed -n 's/.*Bluetooth: hci[0-9]\+: Found device firmware: //p' | sort -u)

  printf '%s\n' "${files[@]}"
}

write_dropins() {
  local -a modules=()
  local -a files=()

  mapfile -t modules < <(detect_modules)
  mapfile -t files < <(detect_firmware_files)

  sudo install -d /etc/mkinitcpio.conf.d
  printf 'MODULES+=(%s)\n' "${modules[*]}" | sudo tee "$modules_path" >/dev/null

  if ((${#files[@]} == 0)); then
    sudo rm -f "$files_path"
  else
    printf 'FILES+=(%s)\n' "${files[*]}" | sudo tee "$files_path" >/dev/null
  fi
}

verify_image() {
  local image_path
  local image_contents
  local entry
  local -a modules=()
  local -a files=()
  local -a required_entries=(
    "usr/lib/bluetooth/bluetoothd"
    "usr/bin/bluetoothctl"
    "etc/bluetooth/main.conf"
    "etc/dbus-1/system.d/org.bluez.conf"
  )

  if [[ -f /boot/EFI/Linux/omarchy_linux.efi ]]; then
    image_path=/boot/EFI/Linux/omarchy_linux.efi
  elif [[ -f /boot/initramfs-linux.img ]]; then
    image_path=/boot/initramfs-linux.img
  else
    printf 'Warning: no boot image was found for verification.\n' >&2
    return 0
  fi

  image_contents=$(sudo lsinitcpio "$image_path")
  mapfile -t modules < <(detect_modules)
  mapfile -t files < <(detect_firmware_files)

  for entry in "${required_entries[@]}"; do
    if ! grep -Fq "$entry" <<<"$image_contents"; then
      printf 'Warning: %s was not found in %s\n' "$entry" "$image_path" >&2
    fi
  done

  for entry in "${modules[@]}"; do
    if ! grep -Fq "/${entry}.ko" <<<"$image_contents"; then
      printf 'Warning: module %s was not found in %s\n' "$entry" "$image_path" >&2
    fi
  done

  for entry in "${files[@]}"; do
    if ! grep -Fq "${entry#/}" <<<"$image_contents"; then
      printf 'Warning: firmware %s was not found in %s\n' "${entry#/}" "$image_path" >&2
    fi
  done
}

main() {
  printf 'Installing Bluetooth initramfs dependencies...\n'
  omarchy-pkg-add bluez bluez-utils dbus
  omarchy-pkg-aur-add mkinitcpio-bluetooth

  printf 'Configuring Bluetooth auto-enable...\n'
  set_auto_enable

  printf 'Updating mkinitcpio hooks and drop-ins...\n'
  update_hooks
  write_dropins

  printf 'Rebuilding initramfs...\n'
  if command -v limine-mkinitcpio >/dev/null 2>&1; then
    sudo limine-mkinitcpio -P
  else
    sudo mkinitcpio -P
  fi

  printf 'Verifying boot image...\n'
  verify_image

  printf 'Bluetooth initramfs unlock configuration is in place.\n'
  printf 'Your keyboard still needs to be paired and trusted in the normal OS.\n'
}

main "$@"
