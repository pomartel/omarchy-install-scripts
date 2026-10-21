# Superwhisper dictation tool. Processing and language are managed in the app.
omarchy-pkg-add superwhisper-bin

if ! systemctl --user is-enabled --quiet superwhisper.service; then
  bash /usr/share/superwhisper/setup-user
fi

(
  deadline=$((SECONDS + 3600))
  models=$(superwhisper models show) || exit
  download_state=$(jq -r '.models[] | select(.id == "transcription") | .download.state' <<<"$models")
  [[ $download_state != installed ]] || exit 0

  if [[ $download_state != downloading ]]; then
    echo "Downloading Superwhisper Parakeet model"
    superwhisper models download transcription >/dev/null || exit
  fi

  while true; do
    models=$(superwhisper models show) || exit
    download_state=$(jq -r '.models[] | select(.id == "transcription") | .download.state' <<<"$models")
    [[ $download_state != installed ]] || exit 0
    if [[ $download_state != downloading ]] || ((SECONDS >= deadline)); then
      echo "Superwhisper Parakeet download did not finish (state: $download_state)." >&2
      exit 1
    fi
    sleep 2
  done
)
