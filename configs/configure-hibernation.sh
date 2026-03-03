#!/bin/bash

printf '%s\n' '[Sleep]' 'HibernateDelaySec=24h' 'HibernateOnACPower=no' | sudo tee /etc/systemd/sleep.conf.d/hibernate.conf >/dev/null

printf '%s\n' '[Login]' 'HandleLidSwitch=suspend-then-hibernate' | sudo tee /etc/systemd/logind.conf.d/lid.conf >/dev/null
