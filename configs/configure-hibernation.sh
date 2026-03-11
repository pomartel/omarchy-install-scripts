#!/bin/bash

sudo tee /etc/systemd/sleep.conf.d/hibernate.conf >/dev/null <<EOF
[Sleep]
HibernateDelaySec=24h
HibernateOnACPower=no
EOF

sudo tee /etc/systemd/logind.conf.d/lid.conf >/dev/null <<EOF
[Login]
HandleLidSwitch=suspend-then-hibernate
EOF
