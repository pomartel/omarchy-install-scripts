#!/bin/bash

if [ "$INSTALL_TARGET" = "school" ]; then
  exit 0
fi

service=config-backup.timer
if ! systemctl is-active --user --quiet "$service"; then
  systemctl --user enable --now "$service"
  echo "Started $service"
fi
