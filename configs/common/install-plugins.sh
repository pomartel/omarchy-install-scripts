plugins=$(omarchy-plugin-list --json) || return

ensure_omarchy_plugin() {
  local plugin_id="$1"
  local repository="$2"
  local plugin_url="https://github.com/$repository.git"

  # YADM manages plugin activation and placement in each host's shell.json.
  if ! jq -e --arg id "$plugin_id" 'any(.[]; .id == $id)' <<<"$plugins" >/dev/null; then
    omarchy-plugin-add "$plugin_url" --yes || return
  fi
}

ensure_omarchy_plugin "pomartel.omacal" "pomartel/omacal"
ensure_omarchy_plugin "pomartel.omatasks" "pomartel/omatasks"
ensure_omarchy_plugin "qs-yadm" "pomartel/qs-yadm"
ensure_omarchy_plugin "tornikegomareli.spaces" "tornikegomareli/omarchy-spaces"
ensure_omarchy_plugin "crmne.hyprmoncfg" "crmne/omarchy-hyprmoncfg"
ensure_omarchy_plugin "keyboard-backlight" "pomartel/keyboard-backlight"

if [ "$HOSTNAME" = "lenovo" ]; then
  ensure_omarchy_plugin "jankeesvw.time-machine" "jankeesvw/omarchy-time-machine"
fi

unset -f ensure_omarchy_plugin
