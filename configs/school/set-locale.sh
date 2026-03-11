#!/bin/bash

current_locale=$(locale | grep LANG=)
target_locale="LANG=fr_CA.UTF-8"

if [[ "$current_locale" != "$target_locale" ]]; then
  echo "Setting system locale to $target_locale..."
  sudo localectl set-locale "$target_locale"
fi
