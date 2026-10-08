# Use the official AppImage: the AUR package predates Marp support.
(
  set -euo pipefail
  version=0.8.0
  checksum=3a8f13a7bc51f76e3b2d124ea428e98f8b53cf37fd22ee254e0f113a35e887f2
  app_dir="$HOME/.local/opt/mermark-editor"
  app="$app_dir/MerMark.Editor_$version.AppImage"
  icon="$app_dir/mermark-editor.png"
  desktop="$HOME/.local/share/applications/mermark-editor.desktop"

  if omarchy-pkg-missing fuse2; then
    omarchy pkg add fuse2
  fi

  if [[ ! -x "$app" || ! -f "$icon" ]]; then
    staging=$(mktemp -d)
    trap 'rm -rf "$staging"' EXIT
    mkdir -p "$app_dir"
    if [[ ! -x "$app" ]]; then
      curl -fL --retry 3 -o "$staging/MerMark.AppImage" \
        "https://github.com/Vesperino/MerMarkEditor/releases/download/v$version/MerMark.Editor_${version}_amd64.AppImage"
      printf '%s  %s\n' "$checksum" "$staging/MerMark.AppImage" | sha256sum -c -
      install -m 755 "$staging/MerMark.AppImage" "$app"
    fi
    if [[ ! -f "$icon" ]]; then
      (cd "$staging" && "$app" --appimage-extract > /dev/null)
      install -m 644 "$staging/squashfs-root/usr/share/icons/hicolor/512x512/apps/mdreader.png" "$icon"
    fi
  fi

  entry="[Desktop Entry]
Type=Application
Name=MerMark Editor
Comment=Markdown and Marp presentation editor
Exec=\"$app\" %U
Icon=$icon
Terminal=false
Categories=Office;
StartupWMClass=mdreader
MimeType=text/markdown;x-scheme-handler/mermark;"
  if [[ ! -f "$desktop" ]] || [[ $(cat "$desktop") != "$entry" ]]; then
    mkdir -p "$(dirname "$desktop")"
    printf '%s\n' "$entry" > "$desktop"
    update-desktop-database "$HOME/.local/share/applications"
  fi
)
