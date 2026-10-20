anylist_desktop="$HOME/.local/share/applications/Anylist.desktop"
anylist_icon="$HOME/.local/share/icons/hicolor/256x256/apps/anylist.png"

# Also migrate existing launchers that still reference the old YADM icon.
if [[ ! -f "$anylist_desktop" || ! -f "$anylist_icon" ]] ||
  ! rg -Fxq "Icon=anylist" "$anylist_desktop"; then
  omarchy-webapp-install Anylist https://anylist.com/web \
    https://www.anylist.com/static/website/images/footer_appicon.png >/dev/null
fi

unset anylist_desktop anylist_icon
