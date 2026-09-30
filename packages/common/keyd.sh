# keyd keyboard remapper
omarchy-pkg-add keyd

if ! systemctl is-active --quiet keyd; then
  sudo systemctl enable --now keyd
fi

keyd_config_file="$HOME/.config/keyd/default.conf"
keyd_config_symlink="/etc/keyd/default.conf"

if [[ -e "$keyd_config_symlink" && ! -L "$keyd_config_symlink" ]]; then
  echo "Preserving existing $keyd_config_symlink; move it aside before linking the YADM config." >&2
  exit 1
fi

if [[ ! -L "$keyd_config_symlink" || $(readlink "$keyd_config_symlink") != "$keyd_config_file" ]]; then
  echo "Setting up symlink for keyd config..."
  sudo ln -sfn "$keyd_config_file" "$keyd_config_symlink"
  sudo systemctl restart keyd
fi
unset keyd_config_file keyd_config_symlink
