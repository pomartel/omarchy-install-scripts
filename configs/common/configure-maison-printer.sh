#!/bin/bash

# The saved driver profile allows setup while the printer is offline.
(
  set -euo pipefail
  maison_uri='ipp://HP%20LaserJet%20Professional%20P1102w._ipp._tcp.local/'
  maison_assets="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/maison-printer"
  if ! lpstat -p Maison >/dev/null 2>&1; then
    sudo lpadmin -p Maison -E -v "$maison_uri" -P "$maison_assets/Maison.ppd" \
      -D Maison -L Maison -o printer-error-policy=retry-job \
      -o PageSize=Letter -o sides-default=one-sided \
      -o print-color-mode-default=monochrome
    # Preserve an existing school printer as the default on Asus.
    if ! LC_ALL=C lpstat -d | grep -q '^system default destination:'; then
      sudo lpadmin -d Maison
    fi
    printf 'Maison: created the HP LaserJet P1102w print queue.\n'
  else
    maison_config=$(sudo awk '
        /^<(Default)?Printer Maison>$/ { maison = 1; next }
        /^<\// { maison = 0 }
        maison { print }
      ' /etc/cups/printers.conf)
    if ! grep -Fxq "DeviceURI $maison_uri" <<<"$maison_config" ||
      ! grep -Fxq 'Info Maison' <<<"$maison_config" ||
      ! grep -Fxq 'ErrorPolicy retry-job' <<<"$maison_config"; then
      sudo lpadmin -p Maison -v "$maison_uri" -D Maison \
        -o printer-error-policy=retry-job
      printf 'Maison: updated printer name, connection and retry policy.\n'
    fi
  fi
  maison_sudoers=/etc/sudoers.d/imprimante-maison
  maison_rule='po ALL=(root) NOPASSWD: /usr/bin/cupsenable Maison'

  if ! printf '%s\n' "$maison_rule" | sudo cmp -s - "$maison_sudoers"; then
    maison_temp=$(mktemp)
    trap 'rm -f "$maison_temp"' EXIT
    printf '%s\n' "$maison_rule" >"$maison_temp"
    sudo visudo -cf "$maison_temp" >/dev/null
    sudo install -o root -g root -m 440 "$maison_temp" "$maison_sudoers"
    printf 'Maison: enabled passwordless printer resume for po.\n'
  fi
  if [[ $(sudo stat -c '%U:%G:%a' "$maison_sudoers") != root:root:440 ]]; then
    sudo chown root:root "$maison_sudoers"
    sudo chmod 440 "$maison_sudoers"
  fi

)
