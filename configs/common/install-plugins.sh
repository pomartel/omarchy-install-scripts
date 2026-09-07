ensure_omarchy_plugin() {
  local plugin_id="$1"
  local plugin_url="$2"
  local project_dir="${3:-}"
  local plugins

  if [ -n "$project_dir" ] && [ ! -d "$HOME/Projects/plugins/$project_dir" ]; then
    git clone "$plugin_url" "$HOME/Projects/plugins/$project_dir"
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
  "https://github.com/pomartel/intemporel.git" \
  "intemporel"
ensure_omarchy_plugin \
  "idle-power" \
  "https://github.com/pomartel/idle-power.git" \
  "idle-power"
ensure_omarchy_plugin \
  "io.github.aryan-techie.todoist" \
  "https://github.com/Aryan-Techie/omarchy-todoist.git"
ensure_omarchy_plugin \
  "qs-yadm" \
  "https://github.com/pomartel/qs-yadm.git" \
  "qs-yadm"

unset -f ensure_omarchy_plugin
