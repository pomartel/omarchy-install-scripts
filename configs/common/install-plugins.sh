ensure_omarchy_plugin() {
  local plugin_id="$1"
  local repository="$2"
  local plugin_url="https://github.com/$repository.git"
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

ensure_omarchy_plugin "intemporel" "pomartel/intemporel"
ensure_omarchy_plugin "idle-power" "pomartel/idle-power"
ensure_omarchy_plugin "omarchy-todoist" "pomartel/omarchy-todoist"
ensure_omarchy_plugin "qs-yadm" "pomartel/qs-yadm"
ensure_omarchy_plugin "crmne.hyprmoncfg" "crmne/omarchy-hyprmoncfg"

if [ "$INSTALL_TARGET" = "lenovo" ]; then
  ensure_omarchy_plugin "jankeesvw.time-machine" "jankeesvw/omarchy-time-machine"
fi

unset -f ensure_omarchy_plugin
