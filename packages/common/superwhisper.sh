# Superwhisper dictation tool. Processing and language are managed in the app.

if ! systemctl --user is-enabled --quiet superwhisper.service; then
  bash /usr/share/superwhisper/setup-user
fi

superwhisper models download transcription
