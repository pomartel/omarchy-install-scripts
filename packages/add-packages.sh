#!/bin/bash
# Helpers are called by the sourced fragments below.
# shellcheck disable=SC1090,SC2329

set -Eeuo pipefail
trap 'printf "Package setup failed at %s:%s\n" "${BASH_SOURCE[0]}" "$LINENO" >&2' ERR

shopt -s nullglob
source ./scripts/migrations.sh

case ${1:---all} in
--pending)
  install_pending_packages=(./migrations/"$INSTALL_TARGET"/packages/{common,"$INSTALL_TARGET"}/*.sh)
  if ((${#install_pending_packages[@]} == 0)); then
    unset install_pending_packages
    if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
      exit 0
    fi
    return 0
  fi
  unset install_pending_packages
  ;;
--all) ;;
*)
  printf 'Usage: %s [--all|--pending]\n' "${BASH_SOURCE[0]}" >&2
  exit 1
  ;;
esac

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

install_run_fragments packages "${1:---all}"

unset -f refresh_install_packages omarchy-pkg-missing omarchy-pkg-add omarchy-pkg-aur-add omarchy
unset install_packages
