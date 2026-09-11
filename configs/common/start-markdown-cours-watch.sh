#!/bin/bash

service=markdown-cours-watch.service
if ! systemctl --user is-active --quiet "$service"; then
  systemctl --user enable --now "$service"
  echo "Started $service"
fi
