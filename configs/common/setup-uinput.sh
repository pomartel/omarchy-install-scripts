#!/bin/bash

# Create a udev rule for the uinput device so members of the input group can access it (solaar)
uinput_rule='KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"'
printf '%s\n' "$uinput_rule" | sudo tee /etc/udev/rules.d/99-uinput.rules >/dev/null
sudo udevadm control --reload-rules
sudo modprobe uinput
sudo udevadm trigger --action=change --subsystem-match=misc --sysname-match=uinput
sudo udevadm settle
