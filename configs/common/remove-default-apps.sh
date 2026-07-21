#!/bin/bash

# Redirect the output to /dev/null to suppress any output if all is good!
omarchy-webapp-remove \
  "Basecamp" \
  "Google Messages" \
  "Google Photos" \
  "HEY" >/dev/null

omarchy-pkg-drop chromium

rm -rf ~/Projects/tries
