# Keep the GitHub-installed app current on each laptop.
(
  set -euo pipefail

  upstream="https://github.com/jankeesvw/omarchy-icloud-photos.git"
  application="${XDG_DATA_HOME:-$HOME/.local/share}/omarchy-icloud-photos"
  cache="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-icloud-photos"
  installed_revision="$cache/installed-revision"

  omarchy pkg add git rsync quickshell imagemagick ffmpeg jq wl-clipboard

  latest=$(git ls-remote --exit-code "$upstream" HEAD | cut -f 1)

  # Installation and its revision record are local to each laptop.
  installed=""
  if [[ -f "$installed_revision" ]]; then
    installed=$(cat "$installed_revision")
  fi

  if [[ "$installed" != "$latest" ]] ||
    [[ ! -x "$HOME/.local/bin/omarchy-icloud-photos" ]] ||
    [[ ! -x "$application/.venv/bin/python" ]]; then
    temporary=$(mktemp -d)
    trap 'rm -rf -- "$temporary"' EXIT
    git clone --quiet --depth 1 "$upstream" "$temporary/repository"
    latest=$(git -C "$temporary/repository" rev-parse HEAD)

    # The upstream installer links to these files, so keep the runtime files
    # in local app storage and only the Git checkout in the temporary directory.
    mkdir -p "$application"
    rm -f -- "$installed_revision"
    rsync -a --delete --exclude='.git' --exclude='.venv' \
      "$temporary/repository/" "$application/"
    bash "$application/install.sh"
    mkdir -p "$cache"
    printf '%s\n' "$latest" >"$installed_revision"
  fi
)
