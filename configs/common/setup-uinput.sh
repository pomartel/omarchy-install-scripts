#!/bin/bash

# Create a udev rule for the uinput device so members of the input group can access it (solaar)
uinput_rule='KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"'
if ! cmp -s <(printf '%s\n' "$uinput_rule") /etc/udev/rules.d/99-uinput.rules; then
  printf '%s\n' "$uinput_rule" | sudo tee /etc/udev/rules.d/99-uinput.rules >/dev/null
fi
unset uinput_rule
