clone_plugin_project_if_missing() {
  local plugin_dir="$1"
  local plugin_url="$2"
  local plugin_path="$HOME/Projects/plugins/$plugin_dir"

  if [ ! -d "$plugin_path" ]; then
    git clone "$plugin_url" "$plugin_path"
  fi
}

ensure_omarchy_plugin() {
  local plugin_id="$1"
  local plugin_url="$2"
  local plugins

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

clone_plugin_project_if_missing \
  "intemporel" \
  "git@github.com:pomartel/intemporel.git"
clone_plugin_project_if_missing \
  "idle-power" \
  "git@github.com:pomartel/idle-power.git"
clone_plugin_project_if_missing \
  "qs-yadm" \
  "git@github.com:pomartel/qs-yadm.git"

ensure_omarchy_plugin \
  "intemporel" \
  "https://github.com/pomartel/intemporel.git"
ensure_omarchy_plugin \
  "idle-power" \
  "https://github.com/pomartel/idle-power.git"
ensure_omarchy_plugin \
  "io.github.aryan-techie.todoist" \
  "https://github.com/Aryan-Techie/omarchy-todoist.git"
ensure_omarchy_plugin \
  "qs-yadm" \
  "https://github.com/pomartel/qs-yadm.git"

unset -f ensure_omarchy_plugin
