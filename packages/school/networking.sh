omarchy-pkg-add networkmanager network-manager-applet wpa_supplicant

# Only add the conf if the file doesn't already exist
wifi_backend_conf="/etc/NetworkManager/conf.d/wifi_backend.conf"
if [ ! -f "$wifi_backend_conf" ]; then
    echo "Configuring NetworkManager to use wpa_supplicant as the Wi-Fi backend..."
    printf "[device]\nwifi.backend=wpa_supplicant\n" | sudo tee "$wifi_backend_conf" >/dev/null
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
