#!/bin/bash

clone_if_missing() {
  local repo="$1"
  local dir="${2:-}"

  if [ -z "$dir" ]; then
    dir="${repo##*/}"
    dir="${dir%.git}"
  fi

  local path="$HOME/Projects/$dir"

  if [ ! -d "$path" ]; then
    mkdir -p "$(dirname "$path")"
    git clone "$repo" "$path"
  fi
}

if [ "$INSTALL_TARGET" = "lenovo" ]; then
  clone_if_missing "git@github.com:pomartel/poll-app.git" "poll/poll-app"
  clone_if_missing "git@github.com:pomartel/fbpoll.co.git" "poll/poll-app.com"
  clone_if_missing "git@github.com:pomartel/coderubik.com.git" "poll/coderubik.com"
  clone_if_missing "https://github.com/pomartel/url-to-pdf-api.git" "poll/url-to-pdf-api"
  clone_if_missing "git@github.com:pomartel/sudomarchy.git"
  clone_if_missing "git@github.com:pomartel/icloud-reminders-keyboard-shortcuts.git"
  clone_if_missing "git@git.dti.crosemont.quebec:pmartel/progression-kolin.git" "Progression/progression-kolin"
  clone_if_missing "git@git.dti.crosemont.quebec:pmartel/sf1.git" "Progression/sf1"
  clone_if_missing "git@git.dti.crosemont.quebec:progression/progression_backend.git" "Progression/progression_backend"
  clone_if_missing "git@git.dti.crosemont.quebec:progression/progression_frontend.git" "Progression/progression_frontend"
  clone_if_missing "git@git.dti.crosemont.quebec:pmartel/java-base.git" "TP-Cours/SF1/java-base"
  clone_if_missing "git@git.dti.crosemont.quebec:pmartel/java-structures-sequentielles.git" "TP-Cours/SF1/java-structures-séquentielles"
fi

clone_if_missing "git@git.dti.crosemont.quebec:pmartel/markdown-to-html.git" "markdown-to-html"
unset -f clone_if_missing
