#!/bin/bash
# Package helpers sourced inside install_run_fragments.
# shellcheck disable=SC2034,SC2329

# Read Pacman's database once on the no-change path. Refresh after installations
# so later fragments see packages pulled in as dependencies as well.
declare -A install_packages=()
refresh_install_packages() {
  local package packages
  packages=$(pacman -Qq) || return
  install_packages=()
  while IFS= read -r package; do
    install_packages["$package"]=1
  done <<<"$packages"
}

omarchy-pkg-missing() {
  local package
  for package in "$@"; do
    [[ -n ${install_packages[$package]:-} ]] || return 0
  done
  return 1
}

omarchy-pkg-add() {
  if omarchy-pkg-missing "$@"; then
    command omarchy-pkg-add "$@" || return
    refresh_install_packages
  fi
}

omarchy-pkg-aur-add() {
  if omarchy-pkg-missing "$@"; then
    command omarchy-pkg-aur-add "$@" || return
    refresh_install_packages
  fi
}

omarchy() {
  case "$*" in
  'pkg add '* | 'pkg aur add '*)
    local -a packages=("${@:3}")
    [[ $2 != aur ]] || packages=("${@:4}")
    if omarchy-pkg-missing "${packages[@]}"; then
      command omarchy "$@" || return
      refresh_install_packages
    fi
    ;;
  *) command omarchy "$@" ;;
  esac
}
