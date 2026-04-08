#!/bin/bash

if ! grep -Rqs 'pam_fprintd\.so' /etc/pam.d; then
  omarchy-setup-fingerprint
  fprintd-enroll -f left-index-finger "$USER"
fi

# Disable fingerprint reader in sudo
sudo sed -i 's/^auth[[:space:]]\+sufficient[[:space:]]\+pam_fprintd\.so$/# &/' /etc/pam.d/sudo
