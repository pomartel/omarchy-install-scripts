if pacman -Q openai-codex-desktop &>/dev/null; then
  # Accept replacement of the conflicting Omarchy package in one transaction.
  yay -S --needed --noconfirm --useask chatgpt-desktop
else
  omarchy pkg aur add chatgpt-desktop
fi

if [ "$(omarchy-default-agent)" != "codex" ]; then
  omarchy-default-agent codex
fi
