# Redis database
omarchy-pkg-add redis

if ! systemctl is-active --quiet redis; then
    sudo systemctl enable --now redis
fi
