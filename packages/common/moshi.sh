# Moshi CLI and agent hook binary
if omarchy-cmd-missing moshi-hook; then
  curl -fsSL https://getmoshi.app/install.sh | MOSHI_HOOK_SKIP_FIRST_RUN=1 sh
fi
