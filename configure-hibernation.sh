#!/bin/bash

# Check if hibernation is already configured
MKINITCPIO_CONF="/etc/mkinitcpio.conf.d/omarchy_resume.conf"
if [ -f "$MKINITCPIO_CONF" ] && grep -q "^HOOKS+=(resume)$" "$MKINITCPIO_CONF"; then
  exit 0
else
  omarchy-hibernation-setup

  # Modify hibernate.conf to change HibernateDelaySec from 30min to 24h
  sudo sed -i 's/HibernateDelaySec=30min/HibernateDelaySec=24h/g' /etc/systemd/sleep.conf.d/hibernate.conf
fi
