# keyd keyboard remapper
omarchy-pkg-add keyd

sudo systemctl enable --now keyd

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

# Allow the leader indicator to write LED events to keyd's virtual keyboard.
keyd_led_rule="$HOME/.config/udev/rules.d/70-hypr-leader-led.rules"
keyd_led_target="/etc/udev/rules.d/70-hypr-leader-led.rules"
if [[ -f "$keyd_led_rule" ]] && ! cmp -s "$keyd_led_rule" "$keyd_led_target"; then
  echo "Installing keyd leader LED permissions..."
  sudo install -m 644 "$keyd_led_rule" "$keyd_led_target"
  sudo udevadm control --reload-rules
  sudo udevadm trigger --action=change --subsystem-match=input
fi
unset keyd_led_rule keyd_led_target
