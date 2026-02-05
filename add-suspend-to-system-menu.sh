#!/bin/bash

STATE_FILE=~/.local/state/omarchy/toggles/suspend-on

if [[ ! -f $STATE_FILE ]]; then
  mkdir -p "$(dirname $STATE_FILE)"
  touch $STATE_FILE
  notify-send "󰒲   Suspend now available in system menu"
fi
