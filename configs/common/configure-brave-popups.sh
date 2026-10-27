#!/bin/bash

desktop="$HOME/.local/share/applications/brave-origin.desktop"
if yadm -C "$HOME" ls-files --error-unmatch -- .local/share/applications/brave-origin.desktop >/dev/null 2>&1; then
  printf 'Brave desktop entry is managed by YADM; refusing to overwrite it.\n' >&2
  return 1
fi
if [[ -e $desktop || -L $desktop ]]; then
  if [[ -L $desktop ]] || ! grep -qx 'X-Install-Brave-Popups=true' "$desktop"; then
    printf 'Brave desktop entry has local customizations: %s\n' "$desktop" >&2
    return 1
  fi
fi

# Refresh from the packaged entry so desktop actions keep working too.
mkdir -p "$(dirname -- "$desktop")"
sed -e "s|^Exec=brave-origin|Exec=$HOME/bin/brave-origin|" \
  -e '/^\[Desktop Entry\]$/a X-Install-Brave-Popups=true' \
  /usr/share/applications/brave-origin.desktop >"$desktop"
update-desktop-database "$HOME/.local/share/applications"
printf 'Brave popup support configured. Fully quit and reopen Brave to activate it.\n'
