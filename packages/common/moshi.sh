# Moshi CLI and agent hook binary
if omarchy-cmd-missing moshi-hook; then
  curl -fsSL https://getmoshi.app/install.sh | MOSHI_HOOK_SKIP_FIRST_RUN=1 sh
fi

# Codex hooks are supplied by YADM; install the other agent integrations here.
moshi-hook install --target claude,opencode,grok,pi,hermes >/dev/null

if ! systemctl --user cat moshi-hook.service >/dev/null 2>&1; then
  moshi-hook service install
elif ! systemctl --user is-enabled --quiet moshi-hook.service ||
  ! systemctl --user is-active --quiet moshi-hook.service; then
  systemctl --user enable --now moshi-hook.service
fi

# Pairing is per machine and must never be stored in this repository.
if moshi-hook status | grep -q '^status: *unpaired'; then
  echo "Moshi is unpaired: run moshi-hook pair --token <token-from-the-Moshi-app> on this laptop."
fi
