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
    mkdir -p "$HOME/Projects"
    git clone "$repo" "$path"
  fi
}

if [ "$INSTALL_TARGET" = "lenovo" ]; then
  clone_if_missing "git@github.com:pomartel/poll-app.git"
  clone_if_missing "git@github.com:pomartel/fbpoll.co.git" "poll-app.com"
  clone_if_missing "git@github.com:pomartel/coderubik.com.git"
  clone_if_missing "git@github.com:pomartel/sudomarchy"
fi

clone_if_missing "git@git.dti.crosemont.quebec:pmartel/markdown-to-html.git" "markdown-to-html"
unset -f clone_if_missing
