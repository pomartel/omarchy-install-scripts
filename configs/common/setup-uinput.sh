#!/bin/bash

# Create a udev rule for the uinput device so members of the input group can access it (solaar)
echo 'KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/99-uinput.rules
