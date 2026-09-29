#!/bin/bash
# Helpers are called by the sourced fragments below.
# shellcheck disable=SC1090,SC2329

set -euo pipefail

shopt -s nullglob

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

refresh_install_packages

for pkg_script in ./packages/common/*.sh; do
  source "$pkg_script"
done

for pkg_script in ./packages/"$INSTALL_TARGET"/*.sh; do
  source "$pkg_script"
done

unset -f refresh_install_packages omarchy-pkg-missing omarchy-pkg-add omarchy-pkg-aur-add omarchy
unset install_packages
