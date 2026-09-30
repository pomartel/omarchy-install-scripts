#!/bin/bash

if ! grep -Fx 'LANG=fr_CA.UTF-8' /etc/locale.conf >/dev/null; then
  sudo localectl set-locale "LANG=fr_CA.UTF-8"
fi
