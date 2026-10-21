#!/bin/bash

source ./scripts/migrations.sh || exit

install_start_time=$(date +%s.%N)
install_completed=0

# These variables are assigned inside the trap before they are used.
# shellcheck disable=SC2154
trap '
  status=$?
  trap - EXIT
  elapsed=$(awk -v start="$install_start_time" -v end="$(date +%s.%N)" "BEGIN { printf \"%.1f\", end - start }")
  if ((status != 0)); then
    printf "Installation failed: " >&2
    printf "%s scripts completed successfully in %ss.\n" "$install_completed" "$elapsed" >&2
  else
    printf "%s scripts completed successfully in %ss.\n" "$install_completed" "$elapsed"
  fi
  exit "$status"
' EXIT

install_validate_hostname
if [[ -d ./migrations/$HOSTNAME ]]; then
  find "./migrations/$HOSTNAME" -mindepth 1 ! -type d -print0 |
    while IFS= read -r -d '' entry; do
      install_validate_link "$entry"
    done
fi

install_run --pending
