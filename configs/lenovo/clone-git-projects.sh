#!/bin/bash

clone_if_missing() {
  local repo="$1"
  local dir="${2:-}"

  if [ -z "$dir" ]; then
    dir="${repo##*/}"
    dir="${dir%.git}"
  fi

  local path="$HOME/Projects/$dir"
  if [[ "$dir" == /* ]]; then
    path="$dir"
  fi

  if [ ! -d "$path" ]; then
    mkdir -p "$(dirname "$path")"
    git clone "$repo" "$path"
  fi
}

clone_if_missing "git@github.com:pomartel/poll-app.git" "poll/poll-app"
clone_if_missing "git@github.com:pomartel/fbpoll.co.git" "poll/poll-app.com"
clone_if_missing "git@github.com:pomartel/coderubik.com.git" "poll/coderubik.com"
clone_if_missing "https://github.com/pomartel/url-to-pdf-api.git" "poll/url-to-pdf-api"
clone_if_missing "git@github.com:pomartel/sudomarchy.git"
clone_if_missing "git@github.com:pomartel/icloud-reminders-keyboard-shortcuts.git" "$HOME/.local/share/icloud-reminders-keyboard-shortcuts"
clone_if_missing "git@git.dti.crosemont.quebec:pmartel/markdown-to-html.git" "markdown-to-html"

unset -f clone_if_missing
