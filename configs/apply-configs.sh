#!/bin/bash
# shellcheck disable=SC1090

set -Eeuo pipefail
trap 'printf "Configuration failed at %s:%s\n" "${BASH_SOURCE[0]}" "$LINENO" >&2' ERR

shopt -s nullglob
source ./scripts/migrations.sh

case ${1:---all} in
--all | --pending) ;;
*)
  printf 'Usage: %s [--all|--pending]\n' "${BASH_SOURCE[0]}" >&2
  exit 1
  ;;
esac

install_run_fragments configs "${1:---all}"
