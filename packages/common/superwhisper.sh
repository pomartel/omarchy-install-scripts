# Superwhisper dictation tool. Processing and language are managed in the app.
omarchy-pkg-add superwhisper-bin

if ! systemctl --user is-enabled --quiet superwhisper.service; then
  bash /usr/share/superwhisper/setup-user
fi
