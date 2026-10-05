omarchy pkg aur add chatgpt-desktop

if [ "$(omarchy-default-agent)" != "codex" ]; then
  omarchy-default-agent codex
fi
