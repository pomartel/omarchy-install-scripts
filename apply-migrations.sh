#!/bin/bash

source ./scripts/migrations.sh || exit

install_start_time=$EPOCHREALTIME
install_completed=0
install_repo=$PWD
install_removed=()

# These variables are assigned inside the trap before they are used.
# shellcheck disable=SC2154
trap '
  status=$?
  if ! install_commit_migrations "$install_repo"; then
    printf "Could not commit or push completed migrations; check Git and retry manually.\n" >&2
    if ((status == 0)); then
      status=1
    fi
  fi
  elapsed=$(awk -v start="$install_start_time" -v end="$EPOCHREALTIME" "BEGIN { printf \"%.1f\", end - start }")
  if ((status != 0)); then
    exec >&2
    printf "Installation failed: "
  fi
  printf "%s scripts completed successfully in %ss.\n" "$install_completed" "$elapsed"
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
