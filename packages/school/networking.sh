omarchy-pkg-add networkmanager network-manager-applet wpa_supplicant

sudo tee "/etc/NetworkManager/conf.d/wifi_backend.conf" >/dev/null <<EOF
[device]
wifi.backend=wpa_supplicant
EOF

sudo tee "/etc/NetworkManager/conf.d/00-mac-address.conf" >/dev/null <<EOF
[device]
wifi.scan-rand-mac-address=no

[connection]
wifi.cloned-mac-address=permanent
ethernet.cloned-mac-address=preserve
EOF

if systemctl is-active --quiet iwd; then
  echo "Disabling iwd to avoid conflicts with NetworkManager..."
  systemctl disable --now iwd
fi

if ! systemctl is-active --quiet wpa_supplicant; then
  sudo systemctl enable --now wpa_supplicant
fi

if systemctl is-active --quiet systemd-networkd; then
  echo "Disabling systemd-networkd to avoid conflicts with NetworkManager..."
  systemctl disable --now systemd-networkd
fi

if ! systemctl is-active --quiet NetworkManager; then
  sudo systemctl enable --now NetworkManager
fi

NM_APPLET_DESKTOP="/etc/xdg/autostart/nm-applet.desktop"
if [ -f "$NM_APPLET_DESKTOP" ]; then
  sudo rm "$NM_APPLET_DESKTOP"
fi
