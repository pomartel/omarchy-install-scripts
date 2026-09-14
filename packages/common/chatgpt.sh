
omarchy pkg add openai-codex-desktop

if [ "$(omarchy-default-agent)" != "codex" ]; then
  omarchy-default-agent codex
fi
