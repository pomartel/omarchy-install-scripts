if [[ ! -x /usr/lib/systemd/system-sleep/omarchy-sleep-stats ]]; then
  sudo install -m 755 scripts/system-sleep/omarchy-sleep-stats /usr/lib/systemd/system-sleep/local-omarchy-sleep-stats
fi
