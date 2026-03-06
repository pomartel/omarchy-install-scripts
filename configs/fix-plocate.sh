sudo install -d /etc/systemd/system/plocate-updatedb.timer.d

sudo tee /etc/systemd/system/plocate-updatedb.timer.d/monotonic.conf >/dev/null <<'EOF'
[Timer]
OnCalendar=
OnBootSec=15min
OnUnitActiveSec=1d
RandomizedDelaySec=1h
AccuracySec=6h
Persistent=false
EOF

sudo install -d /etc/systemd/system/plocate-updatedb.service.d/

sudo tee /etc/systemd/system/plocate-updatedb.service.d/config-file.conf >/dev/null <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/updatedb --config-file=/home/po/.config/plocate/updatedb.conf
EOF

sudo systemctl daemon-reload
sudo systemctl restart plocate-updatedb.timer
