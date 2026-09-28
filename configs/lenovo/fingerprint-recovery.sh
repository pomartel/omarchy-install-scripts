#!/bin/bash

# Pinned Omarchy PR #7158; see fingerprint-recovery/README.md.
apply_lenovo_fingerprint_recovery() (
  set -euo pipefail

  # Check the actual host too: INSTALL_TARGET alone can be inherited over SSH.
  [[ $(hostname -s) == lenovo ]] || return 0
  [[ ${INSTALL_TARGET:-lenovo} == lenovo ]] || return 0

  local check_only=0
  case ${1:-} in
  --check) check_only=1 ;;
  "") ;;
  *)
    echo "Usage: bash configs/lenovo/fingerprint-recovery.sh [--check]" >&2
    return 1
    ;;
  esac

  local assets source_dir target_dir plugin_id stage config_source lock_state changed=0
  assets="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/fingerprint-recovery"
  source_dir="${OMARCHY_PATH:-/usr/share/omarchy}/shell/plugins/lock"
  plugin_id="$(id -un).lock"
  target_dir="$HOME/.config/omarchy/plugins/$plugin_id"
  config_source="$HOME/.config/omarchy/shell.json##hostname.lenovo"

  for dependency in patch jq yadm omarchy omarchy-shell; do
    command -v "$dependency" >/dev/null || {
      echo "Missing dependency: $dependency" >&2
      return 1
    }
  done
  [[ -f /etc/pam.d/omarchy-lock-fingerprint ]] || {
    echo "Enroll and enable fingerprint authentication before applying this fix." >&2
    return 1
  }
  # YADM owns the configuration. Only its Lenovo alternate may be changed by
  # the normal Omarchy clone/enable commands; never generate shell.json here.
  [[ -f $config_source && $HOME/.config/omarchy/shell.json -ef $config_source ]] || {
    echo "Pull config-files and run 'yadm alt' first: Lenovo needs its own shell.json alternate." >&2
    return 1
  }
  if [[ -n $(yadm ls-files -- ".config/omarchy/plugins/$plugin_id") ]]; then
    echo "YADM already manages $plugin_id; refusing to overwrite it." >&2
    return 1
  fi

  stage=$(mktemp -d)
  trap 'rm -rf -- "$stage"' EXIT
  mkdir "$stage/plugin"
  cp -aL "$source_dir/." "$stage/plugin/"
  chmod -R u+w "$stage/plugin"
  # Apply in isolation. A future Omarchy version with incompatible changes
  # must fail here, before touching the live plugin or installing the hook.
  patch --batch --forward --fuzz=0 --no-backup-if-mismatch -p1 \
    -d "$stage/plugin" <"$assets/lock.patch" >"$stage/patch.log" 2>&1 || {
    cat "$stage/patch.log" >&2
    echo "The pinned fingerprint patch needs review against this Omarchy version." >&2
    return 1
  }
  cp "$assets/FingerprintModel.js" "$stage/plugin/FingerprintModel.js"
  jq --arg id "$plugin_id" '
    .id = $id | .name = "My Lock Screen" |
    .omarchy.clonedFrom = "omarchy.lock" | del(.omarchy.clonePaths)
  ' "$stage/plugin/manifest.json" >"$stage/manifest.json"
  mv "$stage/manifest.json" "$stage/plugin/manifest.json"
  printf '%s\n' '7158@e77ed414f28382b8efd2e2633795c73ec36c089e' >"$stage/plugin/.fingerprint-recovery"

  if [[ -e $target_dir ]]; then
    # Preserve hand-edited clones. Rebuilding after an Omarchy update needs a
    # deliberate review; it must not discard local changes to authentication.
    if ! diff -qr "$stage/plugin" "$target_dir" >"$stage/diff.log"; then
      cat "$stage/diff.log" >&2
      echo "Existing $plugin_id differs; back it up and review before replacing it." >&2
      return 1
    fi
  fi

  local hook=/usr/lib/systemd/system-sleep/fprintd-resume
  local timeout_dir=/etc/systemd/system/fprintd.service.d
  local timeout_file="$timeout_dir/10-stop-timeout.conf"
  # The stop-only alternative must not race this restart hook.
  if [[ -e /usr/lib/systemd/system-sleep/fprintd-resume-stop ]] ||
    systemctl is-enabled --quiet fprintd-resume.service 2>/dev/null; then
    echo "Another fingerprint resume workaround is installed; reconcile it first." >&2
    return 1
  fi
  for destination in "$hook" "$timeout_file"; do
    if [[ -e $destination ]] && ! cmp -s "$assets/${destination##*/}" "$destination"; then
      echo "Preserving existing $destination; review it before applying this fix." >&2
      return 1
    fi
  done
  ((check_only)) && return 0

  lock_state=$(omarchy-shell lock status)
  jq -e '.secure == false and .requested == false' <<<"$lock_state" >/dev/null || {
    echo "Unlock the desktop before changing the lock plugin." >&2
    return 1
  }
  # Get authorization before clone/enable modifies the user configuration.
  sudo -v
  if [[ ! -e $target_dir ]]; then
    omarchy plugin clone omarchy.lock
    cp -a "$stage/plugin/." "$target_dir/"
    changed=1
  fi
  if ! omarchy plugin list --json | jq -e --arg id "$plugin_id" \
    'any(.[]; .id == $id and .enabled)' >/dev/null; then
    omarchy plugin enable "$plugin_id"
    changed=1
  fi
  if [[ ! -e $hook ]]; then
    sudo install -Dm755 -o root -g root "$assets/fprintd-resume" "$hook"
    echo "Installed fingerprint recovery after resume."
  fi
  if [[ ! -e $timeout_file ]]; then
    sudo install -Dm644 -o root -g root "$assets/10-stop-timeout.conf" "$timeout_file"
    sudo systemctl daemon-reload
    echo "Bound fingerprint daemon stop time to three seconds."
  fi
  if ((changed)); then
    omarchy restart shell
  fi
)

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  apply_lenovo_fingerprint_recovery "$@"
  exit $?
fi

# Keep the result when sourced by apply-configs.sh, even without caller errexit.
cleanup_lenovo_fingerprint_recovery() {
  unset -f apply_lenovo_fingerprint_recovery cleanup_lenovo_fingerprint_recovery
  return "$1"
}
apply_lenovo_fingerprint_recovery
cleanup_lenovo_fingerprint_recovery "$?"
