# Spotify desktop client
if omarchy-cmd-missing spotify; then
  omarchy install service spotify
fi

omarchy pkg aur add spotifast-bin
