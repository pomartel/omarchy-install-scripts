if ! systemctl is-enabled --quiet sshd.service ||
  ! systemctl is-active --quiet sshd.service; then
  omarchy setup security sshd
fi
