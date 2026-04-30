#!/bin/bash
#
if [[ ! -f "$HOME/.config/Typora/themes/github.css" ]]; then
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT

  git clone --depth=1 https://github.com/typora/typora-default-themes.git "$tmp"

  mkdir -p "$HOME/.config/Typora/themes"
  cp -a "$tmp/themes/." "$HOME/.config/Typora/themes/"

  echo "Typora themes installed successfully."
fi
