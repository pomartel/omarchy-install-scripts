#!/bin/bash

source ./scripts/runner.sh || exit

install_validate_hostname
if [[ -d ./migrations/$HOSTNAME ]]; then
  find "./migrations/$HOSTNAME" -mindepth 1 ! -type d -print0 |
    while IFS= read -r -d '' entry; do
      install_validate_link "$entry"
    done
fi

install_run --pending
