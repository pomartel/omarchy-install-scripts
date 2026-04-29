desktop="$HOME/.local/share/applications/Anylist.desktop"

if [[ ! -f "$desktop" ]]; then
  omarchy-webapp-install Anylist https://anylist.com/web https://www.anylist.com/static/img/favicon@2x.png >/dev/null
fi
