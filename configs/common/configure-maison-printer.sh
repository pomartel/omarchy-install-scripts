#!/bin/bash

(
  set -euo pipefail

  if ! lpstat -p Maison >/dev/null 2>&1; then
    sudo lpadmin -p Maison -E \
      -v 'ipp://HP%20LaserJet%20Professional%20P1102w._ipp._tcp.local/' \
      -m everywhere \
      -D Maison -L Maison -o printer-error-policy=retry-job \
      -o PageSize=Letter -o sides-default=one-sided \
      -o print-color-mode-default=monochrome
    if ! LC_ALL=C lpstat -d | grep -q '^system default destination:'; then
      sudo lpadmin -d Maison
    fi
    printf 'Maison: created the HP LaserJet P1102w print queue.\n'
  fi
)
