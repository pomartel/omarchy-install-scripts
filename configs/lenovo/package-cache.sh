omarchy-pkg-add pacman-contrib

sudo install -Dm644 configs/lenovo/package-cache/retention.conf /etc/systemd/system/paccache.service.d/retention.conf
sudo install -Dm644 configs/lenovo/package-cache/yay-cache-prune.service /etc/systemd/system/yay-cache-prune.service
sudo install -Dm755 configs/lenovo/package-cache/prune-yay /usr/local/libexec/prune-yay-cache
sudo systemctl daemon-reload
sudo systemctl enable --now paccache.timer
