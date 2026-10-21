#!/bin/bash

source ./scripts/migrations.sh || exit

install_start_time=$EPOCHREALTIME
install_completed=0

# These variables are assigned inside the trap before they are used.
# shellcheck disable=SC2154
trap '
  status=$?
  install_release_lock
  elapsed=$(awk -v start="$install_start_time" -v end="$EPOCHREALTIME" "BEGIN { printf \"%.1f\", end - start }")
  if ((status != 0)); then
    exec >&2
    printf "Installation failed: "
  fi
  printf "%s scripts completed successfully in %ss.\n" "$install_completed" "$elapsed"
  exit "$status"
' EXIT

install_validate_hostname
install_acquire_lock
if [[ -d ./migrations/$HOSTNAME ]]; then
  find "./migrations/$HOSTNAME" -mindepth 1 ! -type d -print0 |
    while IFS= read -r -d '' entry; do
      install_validate_link "$entry"
    done
fi

install_run --pending
