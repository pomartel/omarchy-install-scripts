# keyd keyboard remapper
omarchy-pkg-add keyd

if ! systemctl is-active --quiet keyd; then
  sudo systemctl enable --now keyd
fi

KEYD_CONFIG_FILE="$HOME/.config/keyd/default.conf"
KEYD_CONFIG_SYMLINK="/etc/keyd/default.conf"

if [ ! -L "$KEYD_CONFIG_SYMLINK" ]; then
  echo "Setting up symlink for keyd config..."
  sudo rm "$KEYD_CONFIG_SYMLINK"
  sudo ln -sfn "$KEYD_CONFIG_FILE" "$KEYD_CONFIG_SYMLINK"
  sudo systemctl restart keyd
fi
