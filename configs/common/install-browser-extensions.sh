#!/bin/bash

install_browser_extensions() {
  local extension path
  for extension in browser-tab-focus icloud-reminders-keyboard-shortcuts; do
    path="$HOME/.local/share/$extension"
    if [[ ! -e "$path" && ! -L "$path" ]]; then
      mkdir -p "$HOME/.local/share"
      git clone "git@github.com:pomartel/$extension.git" "$path"
    fi
  done
}

install_browser_extensions
unset -f install_browser_extensions
