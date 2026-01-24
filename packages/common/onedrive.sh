omarchy-pkg-aur-add onedrive-abraunegg

if ! systemctl is-active --quiet --user onedrive; then
    onedrive
    systemctl enable --now --user onedrive
fi
