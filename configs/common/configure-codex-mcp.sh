# shellcheck shell=bash

codex_config_file="$HOME/.codex/config.toml"

mkdir -p "$(dirname "$codex_config_file")"

if [ ! -f "$codex_config_file" ]; then
  touch "$codex_config_file"
fi

if ! grep -qF '[mcp_servers.onepassword]' "$codex_config_file"; then
  cat >>"$codex_config_file" <<'EOF'

[mcp_servers.onepassword]
command = "/opt/1Password/1password-mcp"
startup_timeout_sec = 30.0
EOF
  echo "Configured the 1Password MCP server for Codex."
fi

unset codex_config_file
