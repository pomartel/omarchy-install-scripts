anylist_desktop="$HOME/.local/share/applications/Anylist.desktop"
anylist_icon="$HOME/.local/share/applications/icons/Anylist.png"

# YADM supplies the high-resolution icon; keep it as the single source.
if [[ -f "$anylist_icon" ]]; then
  if [[ ! -f "$anylist_desktop" ]]; then
    omarchy-webapp-install Anylist https://anylist.com/web anylist >/dev/null
  fi

  if ! rg -Fxq "Icon=$anylist_icon" "$anylist_desktop"; then
    desktop-file-edit --set-icon="$anylist_icon" "$anylist_desktop"
    update-desktop-database "$HOME/.local/share/applications"
  fi
else
  echo "AnyList: restore the icon with YADM, then rerun INSTALL.sh." >&2
fi

unset anylist_desktop anylist_icon
