#!/bin/bash

sudoers_file="/etc/sudoers.d/custom-sudoers-rules"

sudo tee "$sudoers_file" >/dev/null <<EOF
Defaults timestamp_timeout=60
Defaults !tty_tickets

po ALL=(root) NOPASSWD: /usr/bin/tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference
EOF

sudo chmod 600 "$sudoers_file"
