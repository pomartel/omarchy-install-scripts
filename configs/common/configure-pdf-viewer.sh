#!/bin/bash

# Open new PDF documents at 100% instead of fitting them to the window.
if gsettings list-schemas | rg -qx org.gnome.Evince.Default; then
  if [[ $(gsettings get org.gnome.Evince.Default sizing-mode) != "'free'" ]]; then
    gsettings set org.gnome.Evince.Default sizing-mode free
  fi
  if [[ $(gsettings get org.gnome.Evince.Default zoom) != 1.0 ]]; then
    gsettings set org.gnome.Evince.Default zoom 1.0
  fi
fi
