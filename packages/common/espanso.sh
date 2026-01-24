# Espanso text expander
omarchy-pkg-aur-add espanso-wayland

if ! systemctl is-active --user --quiet espanso; then
    espanso service register
    espanso start
fi
