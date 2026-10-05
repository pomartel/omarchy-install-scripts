#!/bin/bash

# Fit new PDF documents to the width of the viewer window.
if gsettings list-schemas | rg -qx org.gnome.Evince.Default; then
  if [[ $(gsettings get org.gnome.Evince.Default sizing-mode) != "'fit-width'" ]]; then
    gsettings set org.gnome.Evince.Default sizing-mode fit-width
  fi
fi
