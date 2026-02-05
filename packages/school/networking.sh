omarchy-pkg-add networkmanager network-manager-applet wpa_supplicant

# Only add the conf if the file doesn't already exist
wifi_backend_conf="/etc/NetworkManager/conf.d/wifi_backend.conf"
if [ ! -f "$wifi_backend_conf" ]; then
  echo "Configuring NetworkManager to use wpa_supplicant as the Wi-Fi backend..."
  printf "[device]\nwifi.backend=wpa_supplicant\n" | sudo tee "$wifi_backend_conf"
fi

# Only add the conf if the file doesn't already exist
mac_address_conf="/etc/NetworkManager/conf.d/00-mac-address.conf"
if [ ! -f "$mac_address_conf" ]; then
  echo "Configuring NetworkManager MAC address settings..."
  printf "[device]\n" \
    "wifi.scan-rand-mac-address=no\n" \
    "\n" \
    "[connection]\n" \
    "wifi.cloned-mac-address=preserve\n" \
    "ethernet.cloned-mac-address=preserve\n" | sudo tee "$mac_address_conf"
fi

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

nmaplet_autostart_file="/etc/xdg/autostart/nm-applet.desktop"
if [ -f "$nmaplet_autostart_file" ]; then
  echo "Removing nm-applet from autostart..."
  sudo rm "$nmaplet_autostart_file"
fi
