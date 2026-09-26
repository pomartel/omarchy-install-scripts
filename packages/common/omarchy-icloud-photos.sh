# Keep the GitHub-installed app current on each laptop.
(
  set -euo pipefail

  repository="$HOME/Documents/github.com/jankeesvw/omarchy-icloud-photos"
  cache="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-icloud-photos"
  installed_revision="$cache/installed-revision"

  omarchy pkg add git quickshell imagemagick ffmpeg jq wl-clipboard

  if [[ ! -d "$repository" ]]; then
    mkdir -p "$(dirname "$repository")"
    git clone https://github.com/jankeesvw/omarchy-icloud-photos.git "$repository"
  fi

  git -C "$repository" fetch --quiet origin HEAD
  latest=$(git -C "$repository" rev-parse FETCH_HEAD)
  current=$(git -C "$repository" rev-parse HEAD)

  if [[ "$current" != "$latest" ]]; then
    if [[ -n "$(git -C "$repository" status --porcelain)" ]] ||
      ! git -C "$repository" merge-base --is-ancestor HEAD "$latest"; then
      echo "Cannot update Omarchy iCloud Photos: the checkout has local changes or commits." >&2
      exit 1
    fi
    git -C "$repository" merge --ff-only "$latest"
  fi

  # Store this outside the Dropbox-synced checkout: installation is per laptop.
  installed=""
  if [[ -f "$installed_revision" ]]; then
    installed=$(cat "$installed_revision")
  fi

  if [[ "$installed" != "$latest" ]] ||
    [[ ! -x "$HOME/.local/bin/omarchy-icloud-photos" ]] ||
    [[ ! -x "$repository/.venv/bin/python" ]]; then
    bash "$repository/install.sh"
    mkdir -p "$cache"
    printf '%s\n' "$latest" >"$installed_revision"
  fi
)
