#!/bin/bash

omarchy pkg add cups cups-filters avahi

for printing_service in cups.service avahi-daemon.service; do
  if ! systemctl is-enabled --quiet "$printing_service" ||
    ! systemctl is-active --quiet "$printing_service"; then
    sudo systemctl enable --now "$printing_service"
  fi
done
unset printing_service
