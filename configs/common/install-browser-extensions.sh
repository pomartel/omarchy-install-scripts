#!/bin/bash

install_browser_extensions() {
  local extension path
  for extension in browser-tab-focus icloud-reminders-keyboard-shortcuts; do
    path="$HOME/.local/share/$extension"
    if [[ ! -e "$path" && ! -L "$path" ]]; then
      mkdir -p "$HOME/.local/share"
      git clone "git@github.com:pomartel/$extension.git" "$path"
      printf '\nPour activer %s dans Brave :\n' "$extension"
      case "$extension" in
      browser-tab-focus)
        printf '  Préparer le relais en exécutant : "%s/browser_tab_focus.py" --install\n' "$path"
        path="$path/extension"
        ;;
      icloud-reminders-keyboard-shortcuts)
        printf "  Désactiver l’ancien userscript Tampermonkey, si présent.\n"
        ;;
      esac
      printf '  1. Ouvrir brave://extensions dans le profil Brave souhaité.\n'
      printf '  2. Activer « Mode développeur ».\n'
      printf "  3. Cliquer sur « Charger l’extension non empaquetée ».\n"
      printf '  4. Sélectionner le dossier : %s\n' "$path"
      if [[ "$extension" == icloud-reminders-keyboard-shortcuts ]]; then
        printf '  5. Recharger la page iCloud Reminders.\n'
      fi
      printf "  Répéter l’activation pour chaque profil Brave et conserver le dossier local.\n\n"
    fi
  done
}

install_browser_extensions
unset -f install_browser_extensions
