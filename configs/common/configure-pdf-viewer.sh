#!/bin/bash

# Fit new PDF documents to the width of the viewer window.
if ! gsettings list-schemas | rg -x org.gnome.Evince.Default >/dev/null; then
  echo "PDF viewer: Evince settings schema is unavailable; configuration remains pending." >&2
  return 1
fi
gsettings set org.gnome.Evince.Default sizing-mode fit-width
