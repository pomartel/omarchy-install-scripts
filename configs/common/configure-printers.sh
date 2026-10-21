#!/bin/bash

set -euo pipefail

for printer in Maison Travail; do
  if lpstat -p "$printer" >/dev/null 2>&1; then
    continue
  fi

  case "$printer" in
  Maison)
    printer_uri='ipp://HP%20LaserJet%20Professional%20P1102w._ipp._tcp.local/'
    printer_location='Maison'
    ;;
  Travail)
    printer_uri='ipp://NPI600539.local:631/ipp/print'
    printer_location='Cégep'
    ;;
  esac

  if ! timeout 8s ipptool -q -T 5 "$printer_uri" \
    /usr/share/cups/ipptool/get-printer-attributes.test; then
    printf '%s: printer unavailable; skipping queue creation.\n' "$printer" >&2
    continue
  fi

  sudo lpadmin -p "$printer" -E \
    -v "$printer_uri" \
    -m everywhere \
    -D "$printer" -L "$printer_location" -o printer-error-policy=retry-job \
    -o PageSize=Letter -o sides-default=one-sided \
    -o print-color-mode-default=monochrome
  if ! LC_ALL=C lpstat -d | grep -q '^system default destination:'; then
    sudo lpadmin -d "$printer"
  fi
  printf '%s: created the print queue.\n' "$printer"
done
