# Enable Airplay support for Pipewire

omarchy-pkg-add pipewire-zeroconf

# Check if the UFW rule for port 6001/udp already exists, if not, add it
if ! sudo ufw status | grep -q "6001/udp"; then
	echo "Configuring UFW to allow Airplay streaming on port 6001/udp..."
    sudo ufw allow 6001/udp comment "Stream to Airplay"
fi

# Check if the UFW rule for port 6002/udp already exists, if not, add it
if ! sudo ufw status | grep -q "6002/udp"; then
	echo "Configuring UFW to allow Airplay streaming on port 6002/udp..."
    sudo ufw allow 6002/udp comment "Stream to Airplay"
fi
