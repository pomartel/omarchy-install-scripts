# Nginx web server
omarchy-pkg-add nginx mailcap

if ! systemctl is-active --quiet nginx; then
    sudo systemctl enable --now nginx
fi
