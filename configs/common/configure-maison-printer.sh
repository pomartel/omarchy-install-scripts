#!/bin/bash

(
  set -euo pipefail
  maison_assets="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/maison-printer"

  if ! lpstat -p Maison >/dev/null 2>&1; then
    sudo lpadmin -p Maison -E \
      -v 'ipp://HP%20LaserJet%20Professional%20P1102w._ipp._tcp.local/' \
      -P "$maison_assets/Maison.ppd" \
      -D Maison -L Maison -o printer-error-policy=retry-job \
      -o PageSize=Letter -o sides-default=one-sided \
      -o print-color-mode-default=monochrome
    if ! LC_ALL=C lpstat -d | grep -q '^system default destination:'; then
      sudo lpadmin -d Maison
    fi
    printf 'Maison: created the HP LaserJet P1102w print queue.\n'
  fi

  if ! sudo cmp -s "$maison_assets/sudoers" /etc/sudoers.d/imprimante-maison; then
    sudo visudo -cf "$maison_assets/sudoers" >/dev/null
    sudo install -o root -g root -m 440 "$maison_assets/sudoers" /etc/sudoers.d/imprimante-maison
    printf 'Maison: enabled passwordless printer resume for po.\n'
  fi
)
