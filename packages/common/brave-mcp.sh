#!/bin/bash

install_brave_mcp() {
  local version=1.9.0
  local root="$HOME/.local/share/brave-devtools-mcp"
  local installed_version=""

  if [[ -f "$root/server/node_modules/brave-mcp/package.json" ]]; then
    installed_version=$(node -p "require(process.argv[1]).version" "$root/server/node_modules/brave-mcp/package.json")
  fi

  if [[ "$installed_version" != "$version" || ! -f "$root/server/node_modules/brave-mcp/build/src/bin/brave-devtools-mcp.js" ]]; then
    npm install --prefix "$root/server" --no-save --package-lock=false --no-audit --no-fund "brave-mcp@$version"
  fi

  if [[ ! -d "$root/profile" ]]; then
    (
      umask 077
      mkdir -p "$root/profile"
    )
    printf 'Created Brave MCP headless profile: %s\n' "$root/profile"
  fi
}

install_brave_mcp
unset -f install_brave_mcp
