#!/bin/bash

if systemctl is-enabled --quiet no-turbo.service; then
  exit 0
fi

sudo tee /etc/systemd/system/no-turbo.service >/dev/null <<'EOF'
[Unit]
Description=Disable Intel Turbo Boost

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now no-turbo.service
