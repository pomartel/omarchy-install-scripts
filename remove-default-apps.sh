#!/bin/bash

# Redirect the output to /dev/null to suppress any output if all is good!
omarchy-webapp-remove "HEY" >/dev/null
omarchy-webapp-remove "Basecamp" >/dev/null
omarchy-webapp-remove "Google Photos" >/dev/null
omarchy-webapp-remove "Google Messages" >/dev/null
omarchy-webapp-remove "X" >/dev/null
omarchy-webapp-remove "Figma" >/dev/null
omarchy-webapp-remove "Discord" >/dev/null
omarchy-webapp-remove "Zoom" >/dev/null
omarchy-webapp-remove "Fizzy" >/dev/null

omarchy-pkg-drop signal-desktop

# Needed for XCompse which has been replaced by Espanso
omarchy-pkg-add fcitx5-qt fcitx5-gtk fcitx5
