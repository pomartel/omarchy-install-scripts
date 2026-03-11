#!/bin/bash

if systemctl is-active --quiet plocate-updatedb.timer; then
  sudo systemctl mask --now plocate-updatedb.timer
fi
