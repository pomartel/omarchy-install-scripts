#!/bin/bash
# Sourced by the entry points and fragment runners.
# shellcheck disable=SC1090,SC2034,SC2329

install_validate_link() {
  local link=$1 source_path scope filename destination
  source_path=${link#./migrations/"$INSTALL_TARGET"/}
  if [[ ! $source_path =~ ^(packages|configs)/(common|lenovo|asus)/([^/]+\.sh)$ ]]; then
    printf 'Invalid migration path: %s\n' "$link" >&2
    return 1
  fi
  scope=${BASH_REMATCH[2]}
  filename=${BASH_REMATCH[3]}
  if [[ $scope != common && $scope != "$INSTALL_TARGET" ]] || [[ $filename == .* ]]; then
    printf 'Invalid migration target: %s\n' "$link" >&2
    return 1
  fi
  if [[ ! -L $link || ! -f $link || ! -f $source_path ]]; then
    printf 'Invalid or broken migration link: %s\n' "$link" >&2
    return 1
  fi
  destination=$(readlink -- "$link")
  if [[ $destination == /* ]] || [[ $(realpath -e -- "$link") != "$PWD/$source_path" ]]; then
    printf 'Migration must be a relative link to %s: %s\n' "$source_path" "$link" >&2
    return 1
  fi
}

install_validate_queue() {
  local entry
  [[ -d ./migrations/$INSTALL_TARGET ]] || return 0
  find "./migrations/$INSTALL_TARGET" -mindepth 1 ! -type d -print0 |
    while IFS= read -r -d '' entry; do
      install_validate_link "$entry"
    done
}

install_run_fragments() {
  local kind=$1 mode=$2 scope script
  for scope in common "$INSTALL_TARGET"; do
    if [[ $mode == --pending ]]; then
      for script in ./migrations/"$INSTALL_TARGET"/"$kind"/"$scope"/*.sh; do
        install_validate_link "$script"
        source "$script"
        install_completed=$((${install_completed:-0} + 1))
        rm -- "$script"
      done
    else
      for script in ./"$kind"/"$scope"/*.sh; do
        source "$script"
      done
    fi
  done
}
