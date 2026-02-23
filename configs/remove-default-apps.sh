#!/bin/bash

# Redirect the output to /dev/null to suppress any output if all is good!
omarchy-webapp-remove "HEY" >/dev/null
omarchy-webapp-remove "Basecamp" >/dev/null
omarchy-webapp-remove "Google Photos" >/dev/null
omarchy-webapp-remove "Google Messages" >/dev/null
omarchy-webapp-remove "Figma" >/dev/null
omarchy-webapp-remove "Discord" >/dev/null
omarchy-webapp-remove "Zoom" >/dev/null
omarchy-webapp-remove "Fizzy" >/dev/null

omarchy-pkg-drop signal-desktop
omarchy-pkg-drop alacritty

# Temporary
omarchy-pkg-drop noto-fonts-extra
omarchy-pkg-drop ttf-cascadia-mono-nerd
