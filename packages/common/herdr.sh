omarchy pkg aur add herdr-bin

# Node is installed by _node.sh; keybindings and the global wrapper live in YADM.
ensure_herdr_attention_jump() {
  local plugins
  plugins=$(herdr plugin list --json) || return

  if jq -e 'any(.result.plugins[]; .plugin_id == "attention.jump")' <<<"$plugins" >/dev/null; then
    if ! jq -e 'any(.result.plugins[]; .plugin_id == "attention.jump" and .enabled)' <<<"$plugins" >/dev/null; then
      herdr plugin enable attention.jump
    fi
  else
    herdr plugin install milkyskies/herdr-attention --yes
  fi
}

ensure_herdr_attention_jump
unset -f ensure_herdr_attention_jump
