#!/bin/bash

# Remove only installed web apps. `omarchy-webapp-remove` accepts one app name
# per invocation, so passing the list as separate arguments would form one name.
for webapp in \
  "Basecamp" \
  "Discord" \
  "Google" \
  "Google Contacts" \
  "Google Maps" \
  "Google Messages" \
  "Google Photos" \
  "HEY" \
  "Tailscale" \
  "WhatsApp" \
  "X" \
  "YouTube" \
  "Zoom"; do
  if [[ -e "$HOME/.local/share/applications/$webapp.desktop" ]]; then
    omarchy-webapp-remove "$webapp" >/dev/null
  fi
done

omarchy-pkg-drop chromium

# Retired in favor of WhatsApp Web, on both laptops.
omarchy-pkg-drop zapfast-bin
