#!/usr/bin/env bats
# Fixture commands expand these variables in the child Bash process.
# shellcheck disable=SC2016

setup() {
  export INSTALL_REPO="$BATS_TEST_DIRNAME/.."
  export TEST_WORK="$BATS_TEST_TMPDIR/work"
  export HOME="$TEST_WORK/home"
  mkdir -p "$HOME"
}

@test "configuration runner stops at a failed fragment" {
  mkdir -p "$TEST_WORK/configs/common" "$TEST_WORK/configs/lenovo"
  cp "$INSTALL_REPO/configs/apply-configs.sh" "$TEST_WORK/runner.sh"
  printf 'false\n' >"$TEST_WORK/configs/common/01-fail.sh"
  printf 'touch "$TEST_WORK/unexpected"\n' >"$TEST_WORK/configs/common/02-later.sh"
  cp "$TEST_WORK/configs/common/02-later.sh" "$TEST_WORK/configs/lenovo/later.sh"
  run bash -c 'cd "$TEST_WORK"; INSTALL_TARGET=lenovo bash runner.sh'
  [ "$status" -ne 0 ]
  [[ "$output" == *01-fail.sh* ]]
  [ ! -e "$TEST_WORK/unexpected" ]
}

@test "configuration runner applies common scripts before target scripts" {
  mkdir -p "$TEST_WORK/configs/common" "$TEST_WORK/configs/asus"
  cp "$INSTALL_REPO/configs/apply-configs.sh" "$TEST_WORK/runner.sh"
  printf 'echo common >>"$TEST_WORK/order"\n' >"$TEST_WORK/configs/common/01-common.sh"
  printf 'echo asus >>"$TEST_WORK/order"\n' >"$TEST_WORK/configs/asus/01-asus.sh"
  run bash -c 'cd "$TEST_WORK"; INSTALL_TARGET=asus bash runner.sh; cat order'
  [ "$status" -eq 0 ]
  [ "$output" = $'common\nasus' ]
}

@test "project cloning derives optional names and skips existing directories" {
  run bash -euo pipefail -c '
    git() { [[ $1 == clone ]]; mkdir -p "$3"; echo "$3" >>"$TEST_WORK/clones"; }
    INSTALL_TARGET=lenovo
    source "$INSTALL_REPO/configs/common/clone-git-projects.sh"
    source "$INSTALL_REPO/configs/common/clone-git-projects.sh"
    [[ -d "$HOME/Projects/poll-app" && -d "$HOME/Projects/poll-app.com" ]]
    [[ $(wc -l <"$TEST_WORK/clones") == 5 ]]
    ! declare -F clone_if_missing
  '
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "brightness rules contain one percent sign and skip matching content" {
  run bash -euo pipefail -c '
    cmp() { command cmp -s "$2" "$TEST_WORK/rules"; }
    sudo() {
      echo "$*" >>"$TEST_WORK/actions"
      case $1 in
        tee) command tee "$TEST_WORK/rules" ;;
        udevadm) return 0 ;;
        *) return 99 ;;
      esac
    }
    INSTALL_TARGET=lenovo
    source "$INSTALL_REPO/configs/common/configure-auto-display-brightness.sh"
    source "$INSTALL_REPO/configs/common/configure-auto-display-brightness.sh"
    grep -F "set 25%\"" "$TEST_WORK/rules" >/dev/null
    grep -F "set 70%\"" "$TEST_WORK/rules" >/dev/null
    ! grep -F "%%" "$TEST_WORK/rules"
    [[ $(wc -l <"$TEST_WORK/actions") == 2 ]]
  '
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "direct boot configures a missing entry and skips an existing entry" {
  run bash -euo pipefail -c '
    efibootmgr() { echo "$BOOT_ENTRY"; }
    omarchy() { [[ "$*" == "setup direct-boot" ]]; echo configured >>"$TEST_WORK/actions"; }
    BOOT_ENTRY="Boot0001* Other OS"
    source "$INSTALL_REPO/configs/lenovo/enable-direct-boot.sh"
    BOOT_ENTRY="Boot0002* Omarchy HD(1)"
    source "$INSTALL_REPO/configs/lenovo/enable-direct-boot.sh"
    [[ $(wc -l <"$TEST_WORK/actions") == 1 ]]
  '
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "failed boot query does not attempt to configure boot" {
  run bash -euo pipefail -c '
    efibootmgr() { return 42; }
    omarchy() { touch "$TEST_WORK/unexpected"; }
    source "$INSTALL_REPO/configs/lenovo/enable-direct-boot.sh"
  '
  [ "$status" -eq 42 ]
  [ ! -e "$TEST_WORK/unexpected" ]
}

@test "Typora cleanup does not replace the parent exit trap" {
  run bash -euo pipefail -c '
    trap "touch \"$TEST_WORK/parent-trap\"" EXIT
    git() { mkdir -p "$4/themes"; echo theme >"$4/themes/github.css"; }
    source "$INSTALL_REPO/configs/common/install-typora-themes.sh"
    [[ -f "$HOME/.config/Typora/themes/github.css" ]]
  '
  [ "$status" -eq 0 ]
  [ -e "$TEST_WORK/parent-trap" ]
}

@test "failed iCloud upstream check preserves the installed revision" {
  mkdir -p "$HOME/.cache/omarchy-icloud-photos" "$HOME/.local/bin" \
    "$HOME/.local/share/omarchy-icloud-photos/.venv/bin"
  printf revision >"$HOME/.cache/omarchy-icloud-photos/installed-revision"
  touch "$HOME/.local/bin/omarchy-icloud-photos" \
    "$HOME/.local/share/omarchy-icloud-photos/.venv/bin/python"
  chmod +x "$HOME/.local/bin/omarchy-icloud-photos" \
    "$HOME/.local/share/omarchy-icloud-photos/.venv/bin/python"
  run bash -euo pipefail -c '
    unset XDG_DATA_HOME XDG_CACHE_HOME
    omarchy() { [[ "$*" == "pkg add git rsync quickshell imagemagick ffmpeg jq wl-clipboard" ]]; }
    git() { [[ $1 == ls-remote ]]; return 44; }
    source "$INSTALL_REPO/packages/common/omarchy-icloud-photos.sh"
  '
  [ "$status" -eq 44 ]
  [ -z "$output" ]
  [ "$(cat "$HOME/.cache/omarchy-icloud-photos/installed-revision")" = revision ]
}

@test "failed PostgreSQL query does not attempt to create a role" {
  run bash -euo pipefail -c '
    omarchy-pkg-add() { :; }
    systemctl() { :; }
    sudo() {
      if [[ $1 == /usr/bin/bash ]]; then echo initialized; return; fi
      if [[ $3 == psql ]]; then return 43; fi
      touch "$TEST_WORK/unexpected"
    }
    source "$INSTALL_REPO/packages/lenovo/postgresql.sh"
  '
  [ "$status" -eq 43 ]
  [ ! -e "$TEST_WORK/unexpected" ]
}

@test "ordinary iCloud runs always check upstream and skip an unchanged revision" {
  mkdir -p "$HOME/.cache/omarchy-icloud-photos" "$HOME/.local/bin" \
    "$HOME/.local/share/omarchy-icloud-photos/.venv/bin"
  printf revision >"$HOME/.cache/omarchy-icloud-photos/installed-revision"
  touch "$HOME/.local/bin/omarchy-icloud-photos" \
    "$HOME/.local/share/omarchy-icloud-photos/.venv/bin/python"
  chmod +x "$HOME/.local/bin/omarchy-icloud-photos" \
    "$HOME/.local/share/omarchy-icloud-photos/.venv/bin/python"
  run bash -euo pipefail -c '
    unset XDG_DATA_HOME XDG_CACHE_HOME
    omarchy() { :; }
    git() {
      [[ $1 == ls-remote ]]
      echo checked >>"$TEST_WORK/checks"
      printf "revision\tHEAD\n"
    }
    source "$INSTALL_REPO/packages/common/omarchy-icloud-photos.sh"
    source "$INSTALL_REPO/packages/common/omarchy-icloud-photos.sh"
    [[ $(wc -l <"$TEST_WORK/checks") == 2 ]]
  '
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "Voxtype skips model setup when all model assets are present" {
  mkdir -p "$HOME/.local/share/voxtype/models/parakeet-tdt-0.6b-v3-int8"
  for asset in encoder-model.int8.onnx decoder_joint-model.int8.onnx config.json vocab.txt; do
    printf fixture >"$HOME/.local/share/voxtype/models/parakeet-tdt-0.6b-v3-int8/$asset"
  done
  # Replace the absolute setup executable with a failing fixture command.
  sed 's|/usr/lib/voxtype/voxtype-onnx-avx2|unexpected_setup|' \
    "$INSTALL_REPO/packages/common/voxtype.sh" >"$TEST_WORK/voxtype.sh"
  run bash -euo pipefail -c '
    unset XDG_DATA_HOME
    omarchy-pkg-add() { :; }
    systemctl() { [[ "$*" == "--user is-active --quiet voxtype.service" ]]; }
    unexpected_setup() { touch "$TEST_WORK/unexpected"; return 99; }
    source "$TEST_WORK/voxtype.sh"
  '
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ ! -e "$TEST_WORK/unexpected" ]
}

@test "Tailscale enables SSH once and skips enabled state" {
  run bash -euo pipefail -c '
    omarchy-cmd-missing() { return 1; }
    tailscale() {
      if [[ "$*" == "debug prefs" ]]; then
        if [[ -e "$TEST_WORK/ssh" ]]; then echo "{\"RunSSH\":true}"; else echo "{\"RunSSH\":false}"; fi
      else
        [[ "$*" == "set --ssh" ]]
        echo enabled >>"$TEST_WORK/ssh"
      fi
    }
    source "$INSTALL_REPO/packages/common/tailscale.sh"
    source "$INSTALL_REPO/packages/common/tailscale.sh"
    [[ $(wc -l <"$TEST_WORK/ssh") == 1 ]]
  '
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "keyd creates a missing symlink, repairs a wrong link, and skips a correct link" {
  mkdir -p "$TEST_WORK/keyd" "$HOME/.config/keyd"
  printf config >"$HOME/.config/keyd/default.conf"
  sed 's|"/etc/keyd/default.conf"|"$TEST_WORK/keyd/default.conf"|' \
    "$INSTALL_REPO/packages/common/keyd.sh" >"$TEST_WORK/keyd.sh"
  run bash -euo pipefail -c '
    omarchy-pkg-add() { :; }
    systemctl() { :; }
    sudo() {
      case $1 in
        ln) command ln "${@:2}" ;;
        systemctl) echo restarted >>"$TEST_WORK/restarts" ;;
        *) return 99 ;;
      esac
    }
    source "$TEST_WORK/keyd.sh"
    [[ $(readlink "$TEST_WORK/keyd/default.conf") == "$HOME/.config/keyd/default.conf" ]]
    ln -sfn "$HOME/wrong.conf" "$TEST_WORK/keyd/default.conf"
    source "$TEST_WORK/keyd.sh"
    source "$TEST_WORK/keyd.sh"
    [[ $(readlink "$TEST_WORK/keyd/default.conf") == "$HOME/.config/keyd/default.conf" ]]
    [[ $(wc -l <"$TEST_WORK/restarts") == 2 ]]
  '
  [ "$status" -eq 0 ]
}

@test "keyd preserves an existing regular configuration file" {
  mkdir -p "$TEST_WORK/keyd"
  printf original >"$TEST_WORK/keyd/default.conf"
  sed 's|"/etc/keyd/default.conf"|"$TEST_WORK/keyd/default.conf"|' \
    "$INSTALL_REPO/packages/common/keyd.sh" >"$TEST_WORK/keyd.sh"
  run bash -euo pipefail -c '
    omarchy-pkg-add() { :; }
    systemctl() { :; }
    sudo() { touch "$TEST_WORK/unexpected"; }
    source "$TEST_WORK/keyd.sh"
  '
  [ "$status" -eq 1 ]
  [ "$(cat "$TEST_WORK/keyd/default.conf")" = original ]
  [ ! -e "$TEST_WORK/unexpected" ]
}
