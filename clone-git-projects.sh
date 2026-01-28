#!/bin/bash

BASE="$HOME/Work"

clone_if_missing() {
    local repo="$1"
    local dir="$2"

    if [ -z "$dir" ]; then
        dir="$(basename "$repo" .git)"
    fi

    local path="$BASE/$dir"

    if [ ! -d "$path" ]; then
        git clone "$repo" "$path"
    fi
}

if [ "$INSTALL_TARGET" = "home" ]; then
    clone_if_missing "git@github.com:pomartel/poll-app.git"
    clone_if_missing "git@github.com:pomartel/fbpoll.co.git" "poll-app.com"
    clone_if_missing "git@github.com:pomartel/coderubik.com.git"
fi

clone_if_missing "git@git.dti.crosemont.quebec:pmartel/markdown-export.git" "markdown"

clone_if_missing "git@github.com:pomartel/sudomarchy"

clone_if_missing "git@github.com:pomartel/omarchy"