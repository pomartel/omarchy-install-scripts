#!/bin/bash
# shellcheck disable=SC1090

set -Eeuo pipefail
trap 'printf "Configuration failed at %s:%s\n" "${BASH_SOURCE[0]}" "$LINENO" >&2' ERR

shopt -s nullglob

for config_script in ./configs/common/*.sh; do
  source "$config_script"
done

for config_script in ./configs/"$INSTALL_TARGET"/*.sh; do
  source "$config_script"
done
