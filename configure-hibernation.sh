#!/bin/bash

read -r -d '' SLEEP_CONTENT <<'EOF'
[Sleep]
HibernateDelaySec=24h
HibernateOnACPower=no
EOF
printf '%s\n' "$SLEEP_CONTENT" | sudo tee /etc/systemd/sleep.conf.d/hibernate.conf >/dev/null

read -r -d '' LID_CONTENT <<'EOF'
[Login]
HandleLidSwitch=suspend-then-hibernate
EOF
printf '%s\n' "$LID_CONTENT" | sudo tee /etc/systemd/logind.conf.d/lid.conf >/dev/null
