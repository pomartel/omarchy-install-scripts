if omarchy-cmd-missing tailscale; then
  omarchy install service tailscale
fi

tailscale set --ssh
