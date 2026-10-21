#!/bin/bash

for extension in browser-tab-focus icloud-reminders-keyboard-shortcuts; do
  path="$HOME/.local/share/$extension"
  if [[ ! -e "$path" && ! -L "$path" ]]; then
    mkdir -p "$HOME/.local/share"
    git clone "git@github.com:pomartel/$extension.git" "$path"
    printf '\nPour activer %s dans Brave :\n' "$extension"
    if [[ "$extension" == browser-tab-focus ]]; then
      path="$path/extension"
    fi
    printf '  1. Ouvrir brave://extensions.\n'
    printf '  2. Activer « Mode développeur ».\n'
    printf "  3. Cliquer sur « Charger l’extension non empaquetée ».\n"
    printf '  4. Sélectionner le dossier : %s\n' "$path"
  fi
done
