# Drop power-profiles-daemon as it conflicts with TLP
if pacman -Q | grep -q power-profiles-daemon; then
    omarchy-pkg-drop "power-profiles-daemon"
fi

omarchy-pkg-add tlp tlp-pd

if ! systemctl is-active --quiet tlp.service; then
    sudo systemctl enable tlp.service
fi

if ! systemctl is-active --quiet tlp-pd.service; then
    sudo systemctl enable --now tlp-pd.service
    fi

# Check if the systemd-rfkill service and socket are already masked
if systemctl is-enabled systemd-rfkill.service &>/dev/null; then
    echo "Masking systemd-rfkill service and socket..."
    sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
fi

# Check if the symbolic link for the command alias exists before creating it
if [ ! -L /usr/local/bin/powerprofilesctl ]; then
    echo "Creating symbolic link for powerprofilesctl..."
    sudo ln -s /usr/bin/tlpctl /usr/local/bin/powerprofilesctl
fi

# Create the symlink for custom configuration file
TLP_CONFIG_FILE="~/.config/tlp/custom.conf"
TLP_SYMLINK_FILE="/etc/tlp.d/custom.conf"
if [ ! -L "$TLP_SYMLINK_FILE" ]; then
    echo "Creating symlink for $TLP_CONFIG_FILE in /etc/tlp.d/..."
    sudo ln -s "$TLP_CONFIG_FILE" "$TLP_SYMLINK_FILE"
fi

# Start TLP only if it is not already active
if ! systemctl is-active tlp &>/dev/null; then
    echo "Starting TLP..."
    sudo tlp start
fi
