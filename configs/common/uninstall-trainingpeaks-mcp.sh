#!/bin/bash

trainingpeaks_dir="$HOME/MCP/trainingpeaks-mcp"

if codex mcp get trainingpeaks >/dev/null 2>&1; then
  codex mcp remove trainingpeaks
fi

if [ -d "$trainingpeaks_dir" ]; then
  rm -rf "$trainingpeaks_dir"
fi

unset trainingpeaks_dir
