# keyd keyboard remapper
omarchy-pkg-add keyd

echo "Setting up symlink for keyd config..."
sudo ln -sfn "$HOME/.config/keyd/default.conf" "/etc/keyd/default.conf"

# Allow the leader indicator to write LED events to keyd's virtual keyboard.
echo "Installing keyd leader LED permissions..."
sudo install -m 644 "$HOME/.config/udev/rules.d/70-hypr-leader-led.rules" "/etc/udev/rules.d/70-hypr-leader-led.rules"
sudo udevadm control --reload-rules
sudo udevadm trigger --action=change --subsystem-match=input

omarchy-pkg-add keyd
