#!/bin/bash

printers=$(LC_ALL=C lpstat -p | awk '/^printer / { print $2 }')
while IFS= read -r printer; do
  [[ -n $printer ]] || continue
  sudo lpadmin -p "$printer" -o printer-error-policy=retry-job
done <<<"$printers"
