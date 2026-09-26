# Herdr comes with Omarchy; Node is installed by packages/common/_node.sh.
# Keybindings and the global wrapper are managed by YADM.
# Auto Title builds a Go binary during installation.
if omarchy-cmd-missing go; then
  omarchy pkg add go
fi

ensure_herdr_plugin() {
  local plugin_id="$1"
  local repository="$2"
  local plugins
  plugins=$(herdr plugin list --json) || return

  if jq -e --arg id "$plugin_id" 'any(.result.plugins[]; .plugin_id == $id)' <<<"$plugins" >/dev/null; then
    if ! jq -e --arg id "$plugin_id" \
      'any(.result.plugins[]; .plugin_id == $id and .enabled)' <<<"$plugins" >/dev/null; then
      herdr plugin enable "$plugin_id"
    fi
  else
    herdr plugin install "$repository" --yes
  fi
}

ensure_herdr_plugin "attention.jump" "milkyskies/herdr-attention"
ensure_herdr_plugin "herdr.auto-title" "kryptamine/herdr-auto-title"

unset -f ensure_herdr_plugin
