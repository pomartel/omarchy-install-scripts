# Install the latest OmaMarp default-branch commit on both laptops.
install_omamarp() (
  local revision
  local data_dir="${XDG_DATA_HOME:-$HOME/.local/share}"
  local source_dir="${XDG_CACHE_HOME:-$HOME/.cache}/omamarp/source"
  local app_dir="$data_dir/omamarp"

  omarchy pkg add base-devel git qt6-base qt6-declarative qt6-webengine qt6-svg desktop-file-utils

  # Keep the build checkout separate from the development project.
  if [[ ! -d "$source_dir/.git" ]]; then
    mkdir -p "$(dirname "$source_dir")"
    git clone --no-checkout git@github.com:pomartel/OmaMarp.git "$source_dir"
  fi
  # Remote HEAD follows the default branch, even if it is renamed.
  git -C "$source_dir" fetch --quiet origin HEAD
  revision=$(git -C "$source_dir" rev-parse 'FETCH_HEAD^{commit}')

  if [[ -f "$app_dir/installed-revision" ]] &&
    [[ $(< "$app_dir/installed-revision") == "$revision" ]] &&
    [[ -x "$app_dir/bin/omamarp" ]] &&
    [[ -f "$app_dir/preview/render.mjs" ]] &&
    [[ -d "$app_dir/node_modules/@marp-team/marp-core" ]] &&
    [[ -f "$data_dir/applications/omamarp.desktop" ]]; then
    return 0
  fi

  git -C "$source_dir" checkout --detach "$revision"
  "$source_dir/bin/install"
  printf '%s\n' "$revision" > "$app_dir/installed-revision"
)

install_omamarp
unset -f install_omamarp
