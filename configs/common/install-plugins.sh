ensure_omarchy_plugin() {
  local plugin_id="$1"
  local repository="$2"
  local plugin_url="https://github.com/$repository.git"
  local project_path="$HOME/Projects/plugins/$(basename "$repository")"
  local plugins

  if [ ! -d "$project_path" ]; then
    git clone "$plugin_url" "$project_path"
  fi

  plugins=$(omarchy plugin list --json) || return

  if jq -e --arg id "$plugin_id" 'any(.[]; .id == $id)' <<<"$plugins" >/dev/null; then
    if ! jq -e --arg id "$plugin_id" \
      'any(.[]; .id == $id and .enabled)' <<<"$plugins" >/dev/null; then
      omarchy plugin enable "$plugin_id"
    fi
  else
    omarchy plugin add "$plugin_url" --enable --yes
  fi
}

ensure_omarchy_plugin \
  "intemporel" \
  "pomartel/intemporel"
ensure_omarchy_plugin \
  "idle-power" \
  "pomartel/idle-power"
ensure_omarchy_plugin \
  "io.github.aryan-techie.todoist" \
  "Aryan-Techie/omarchy-todoist"
ensure_omarchy_plugin \
  "qs-yadm" \
  "pomartel/qs-yadm"

unset -f ensure_omarchy_plugin
