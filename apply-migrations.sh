#!/bin/bash

set -Eeuo pipefail

install_start_time=$(date +%s.%N)
install_completed=0

install_summary() {
  local status=$? elapsed
  trap - EXIT
  elapsed=$(awk -v start="$install_start_time" -v end="$(date +%s.%N)" 'BEGIN { printf "%.1f", end - start }')
  if ((status != 0)); then
    printf 'Installation failed: ' >&2
    printf '%s scripts completed successfully in %ss.\n' "$install_completed" "$elapsed" >&2
  else
    printf '%s scripts completed successfully in %ss.\n' "$install_completed" "$elapsed"
  fi
  exit "$status"
}
trap install_summary EXIT

source ./scripts/migrations.sh
install_validate_hostname
install_validate_queue

source ./packages/add-packages.sh --pending
source ./configs/apply-configs.sh --pending
