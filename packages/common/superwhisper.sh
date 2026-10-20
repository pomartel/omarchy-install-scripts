# Superwhisper dictation tool. Processing and language are managed in the app.
omarchy-pkg-add superwhisper-bin

if ! systemctl --user is-enabled --quiet superwhisper.service; then
  bash /usr/share/superwhisper/setup-user
fi

if [[ "$(omarchy default dictation 2>/dev/null || true)" != superwhisper ]]; then
  omarchy dictation use superwhisper
fi
