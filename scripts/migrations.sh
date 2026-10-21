#!/bin/bash
# Sourced by the entry points and fragment runners.
# shellcheck disable=SC1090,SC2034,SC2329

set -Eeuo pipefail
shopt -s nullglob
trap 'printf "Setup failed at %s:%s\n" "${BASH_SOURCE[0]}" "$LINENO" >&2' ERR

install_validate_hostname() {
  if [[ $HOSTNAME != lenovo && $HOSTNAME != asus ]]; then
    printf "ERROR: Unsupported hostname '%s'. Expected lenovo or asus.\n" "$HOSTNAME" >&2
    return 1
  fi
}

install_validate_link() {
  local link=$1 source_path scope filename destination
  source_path=${link#./migrations/"$HOSTNAME"/}
  if [[ ! $source_path =~ ^(packages|configs)/(common|lenovo|asus)/([^/]+\.sh)$ ]]; then
    printf 'Invalid migration path: %s\n' "$link" >&2
    return 1
  fi
  scope=${BASH_REMATCH[2]}
  filename=${BASH_REMATCH[3]}
  if [[ $scope != common && $scope != "$HOSTNAME" ]] || [[ $filename == .* ]]; then
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
  [[ -d ./migrations/$HOSTNAME ]] || return 0
  find "./migrations/$HOSTNAME" -mindepth 1 ! -type d -print0 |
    while IFS= read -r -d '' entry; do
      install_validate_link "$entry"
    done
}

install_run_fragments() {
  local kind=$1 mode=$2 root=. script
  case $mode in
  --pending) root=./migrations/$HOSTNAME ;;
  --all) ;;
  *)
    printf 'Invalid execution mode: %s (expected --all or --pending).\n' "$mode" >&2
    return 1
    ;;
  esac

  local -a install_scripts=("$root/$kind/common/"*.sh "$root/$kind/$HOSTNAME/"*.sh)
  ((${#install_scripts[@]} > 0)) || return 0

  for script in "${install_scripts[@]}"; do
    if [[ $mode == --pending ]]; then
      install_validate_link "$script"
    fi
    source "$script"
    if [[ $mode == --pending ]]; then
      install_completed=$((${install_completed:-0} + 1))
      rm -- "$script"
    fi
  done
}

install_run() {
  install_run_fragments packages "$1"
  install_run_fragments configs "$1"
}
