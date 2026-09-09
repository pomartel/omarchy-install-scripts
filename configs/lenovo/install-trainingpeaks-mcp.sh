#!/bin/bash

trainingpeaks_dir="$HOME/MCP/trainingpeaks-mcp"
trainingpeaks_repo="https://github.com/JamsusMaximus/trainingpeaks-mcp.git"

if [ ! -d "$trainingpeaks_dir/.git" ]; then
  mkdir -p "$(dirname "$trainingpeaks_dir")"
  git clone "$trainingpeaks_repo" "$trainingpeaks_dir"
fi

if [ ! -x "$trainingpeaks_dir/.venv/bin/tp-mcp" ]; then
  python3 -m venv "$trainingpeaks_dir/.venv"
  "$trainingpeaks_dir/.venv/bin/pip" install --upgrade pip
  "$trainingpeaks_dir/.venv/bin/pip" install -e "$trainingpeaks_dir"
fi

if ! codex mcp list 2>/dev/null | awk 'NR > 1 { print $1 }' | grep -qx trainingpeaks; then
  codex mcp add trainingpeaks -- "$trainingpeaks_dir/.venv/bin/tp-mcp" serve
fi

unset trainingpeaks_dir trainingpeaks_repo
