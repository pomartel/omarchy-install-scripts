#!/bin/bash

install_op_service() {
  local source='./scripts/op-service'
  local destination="$HOME/bin/op-service"
  mkdir -p "$HOME/bin"
  if ! cmp -s "$source" "$destination" || [[ ! -x "$destination" ]]; then
    install -m 755 "$source" "$destination"
    printf 'Installed %s\n' "$destination"
  fi
}

install_op_service
unset -f install_op_service
