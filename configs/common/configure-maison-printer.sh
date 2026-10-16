#!/bin/bash

# Skip computers where the home printer has not been configured.
if command -v lpstat >/dev/null && lpstat -p Maison >/dev/null 2>&1; then
  (
    set -euo pipefail
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

    if ! sudo awk '
      /^<(Default)?Printer Maison>$/ { maison = 1 }
      maison && $1 == "ErrorPolicy" && $2 == "retry-job" { found = 1 }
      /^<\// { maison = 0 }
      END { exit !found }
    ' /etc/cups/printers.conf; then
      sudo lpadmin -p Maison -o printer-error-policy=retry-job
      printf 'Maison: enabled automatic job retries after errors.\n'
    fi
  )
fi
