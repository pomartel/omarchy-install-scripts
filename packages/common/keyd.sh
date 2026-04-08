# keyd keyboard remapper
omarchy-pkg-add keyd

if ! systemctl is-active --quiet keyd; then
  sudo systemctl enable --now keyd
fi

keyd_config_file="$HOME/.config/keyd/default.conf"
keyd_config_symlink="/etc/keyd/default.conf"

if [ ! -L "$keyd_config_symlink" ]; then
  echo "Setting up symlink for keyd config..."
  sudo rm "$keyd_config_symlink"
  sudo ln -sfn "$keyd_config_file" "$keyd_config_symlink"
  sudo systemctl restart keyd
fi
