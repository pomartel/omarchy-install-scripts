#!/bin/bash

install_browser_extensions() {
  local extension path cloned relay_output relay_manifest
  for extension in browser-tab-focus icloud-reminders-keyboard-shortcuts; do
    path="$HOME/.local/share/$extension"
    cloned=0
    if [[ ! -e "$path" && ! -L "$path" ]]; then
      mkdir -p "$HOME/.local/share"
      git clone "git@github.com:pomartel/$extension.git" "$path"
      cloned=1
    fi
    if [[ "$extension" == browser-tab-focus ]]; then
      relay_manifest="$HOME/.config/BraveSoftware/Brave-Origin/NativeMessagingHosts/com.pomartel.browser_tab_focus.json"
      if yadm -C "$HOME" ls-files --error-unmatch "${relay_manifest#"$HOME/"}" >/dev/null 2>&1; then
        printf 'Le relais est géré par YADM : %s\n' "$relay_manifest" >&2
      else
        relay_output=$("$path/browser_tab_focus.py" --install) || return
        if [[ "$relay_output" == Installed* ]]; then
          printf '%s\n' "${relay_output%%$'\n'*}"
        fi
      fi
    fi
    if [[ "$cloned" == 1 ]]; then
      printf '\nPour activer %s dans Brave :\n' "$extension"
      if [[ "$extension" == browser-tab-focus ]]; then
        path="$path/extension"
      fi
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
