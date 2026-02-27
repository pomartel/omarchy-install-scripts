if ! systemctl is-active --quiet adjust-refresh-rate.service; then
  systemctl --user enable --now adjust-refresh-rate.service
  echo "Starting adjust-refresh-rate.service..."
fi
