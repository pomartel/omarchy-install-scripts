#!/bin/bash
# Shared execution and reporting for bootstrap and pending migrations.
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
  if [[ ! -L $link || ! -f $link ]]; then
    printf 'Invalid or broken migration link: %s\n' "$link" >&2
    return 1
  fi
  destination=$(readlink -- "$link")
  if [[ $destination == /* ]] || [[ $(realpath -e -- "$link") != "$PWD/$source_path" ]]; then
    printf 'Migration must be a relative link to %s: %s\n' "$source_path" "$link" >&2
    return 1
  fi
}

install_commit_migrations() {
  local repo=$1 path
  local -a tracked=()
  for path in "${install_removed[@]}"; do
    if git -C "$repo" ls-files --error-unmatch -- "$path" >/dev/null 2>&1; then
      tracked+=("$path")
    fi
  done
  ((${#tracked[@]} > 0)) || return 0

  # Commit only this run's removed links, leaving unrelated staged changes alone.
  git -C "$repo" commit --only \
    -m "Record completed migrations on $HOSTNAME" -- "${tracked[@]}" || return
  git -C "$repo" push || return
}

install_report_scripts() {
  local end=$1 index duration result
  ((${#install_ran[@]} > 0)) || return 0

  printf '\nScripts run:\n'
  for index in "${!install_ran[@]}"; do
    duration=$(awk -v start="${install_run_starts[$index]}" \
      -v end="${install_run_ends[$index]:-$end}" 'BEGIN { printf "%.2f", end - start }')
    result=completed
    [[ -n ${install_run_ends[$index]:-} ]] || result='not completed'
    printf '  %ss  [%s] %s\n' "$duration" "$result" "${install_ran[$index]}"
  done
  printf '\n'
}

install_run() {
  local mode=$1 root=. script index
  case $mode in
  --pending) root=./migrations/$HOSTNAME ;;
  --all) ;;
  *)
    printf 'Invalid execution mode: %s (expected --all or --pending).\n' "$mode" >&2
    return 1
    ;;
  esac

  local -a install_scripts=(
    "$root/packages/common/"*.sh
    "$root/packages/$HOSTNAME/"*.sh
    "$root/configs/common/"*.sh
    "$root/configs/$HOSTNAME/"*.sh
  )

  for script in "${install_scripts[@]}"; do
    index=${#install_ran[@]}
    install_ran+=("${script#"$root/"}")
    install_run_starts+=("$EPOCHREALTIME")
    source "$script"
    install_run_ends[index]=$EPOCHREALTIME
    if [[ $mode == --pending ]]; then
      rm -- "$script"
      install_removed+=("$script")
    fi
  done
}

install_start_time=$EPOCHREALTIME
install_repo=$PWD
install_removed=()
install_ran=()
install_run_starts=()
install_run_ends=()

# These variables are assigned inside the trap before they are used.
# shellcheck disable=SC2154
trap '
  status=$?
  install_end_time=$EPOCHREALTIME
  if ! install_commit_migrations "$install_repo"; then
    printf "Could not commit or push completed migrations; check Git and retry manually.\n" >&2
    if ((status == 0)); then
      status=1
    fi
  fi
  elapsed=$(awk -v start="$install_start_time" -v end="$EPOCHREALTIME" "BEGIN { printf \"%.1f\", end - start }")
  if ((status != 0)); then
    exec >&2
  fi
  install_report_scripts "$install_end_time"
  if ((status != 0)); then
    printf "Installation failed: "
  fi
  printf "%s scripts completed successfully in %ss.\n" "${#install_run_ends[@]}" "$elapsed"
  exit "$status"
' EXIT
