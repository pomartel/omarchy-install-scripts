# Herdr comes with Omarchy; Node is installed by packages/common/_node.sh.
# Keybindings and the global wrapper are managed by YADM.
# Auto Title builds a Go binary; its mise version is managed by YADM.
if ! go version >/dev/null 2>&1; then
  mise install go
fi

ensure_herdr_plugin() {
  local plugin_id="$1"
  local repository="$2"
  local plugins
  plugins=$(herdr plugin list --json) || return

  if jq -e --arg id "$plugin_id" --arg repo "$repository" \
    'any(.result.plugins[]; .plugin_id == $id and
      ((.source.owner + "/" + .source.repo) == $repo) and
      ((.source.requested_ref // "") == ""))' <<<"$plugins" >/dev/null; then
    if ! jq -e --arg id "$plugin_id" \
      'any(.result.plugins[]; .plugin_id == $id and .enabled)' <<<"$plugins" >/dev/null; then
      herdr plugin enable "$plugin_id"
    fi
  else
    herdr plugin install "$repository" --yes
  fi
}

ensure_herdr_plugin "attention.jump" "pomartel/herdr-attention"
ensure_herdr_plugin "herdr.auto-title" "kryptamine/herdr-auto-title"
ensure_herdr_plugin "herdr-auto-update" "dio16/herdr-auto-update"

# Automatic-update policy is managed by YADM in the plugin's config.toml.

unset -f ensure_herdr_plugin
