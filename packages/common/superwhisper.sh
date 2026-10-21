# Superwhisper dictation tool. Processing and language are managed in the app.
omarchy-pkg-add superwhisper-bin

if ! systemctl --user is-enabled --quiet superwhisper.service; then
  bash /usr/share/superwhisper/setup-user
fi

download_superwhisper_models() {
  local models missing model deadline download_state
  models=$(superwhisper models show) || return
  missing=$(jq -er '.processing as $mode | .processingModes[] | select(.value == $mode) | .missing | join("\n")' <<<"$models") || return

  while IFS= read -r model; do
    [[ -n $model ]] || continue
    deadline=$((SECONDS + 3600))

    # The CLI accepts only one model operation at a time.
    while [[ $(jq -r '.active // empty' <<<"$models") != "" ]]; do
      if ((SECONDS >= deadline)); then
        echo "Timed out waiting for the Superwhisper model download." >&2
        return 1
      fi
      sleep 2
      models=$(superwhisper models show) || return
    done

    download_state=$(jq -r --arg id "$model" '.models[] | select(.id == $id) | .download.state' <<<"$models")
    [[ $download_state != installed ]] || continue
    echo "Downloading Superwhisper model: $model"
    superwhisper models download "$model" >/dev/null || return

    while true; do
      models=$(superwhisper models show) || return
      download_state=$(jq -r --arg id "$model" '.models[] | select(.id == $id) | .download.state' <<<"$models")
      [[ $download_state != installed ]] || break
      if [[ $download_state != downloading ]] || ((SECONDS >= deadline)); then
        echo "Superwhisper model $model did not finish downloading (state: $download_state)." >&2
        return 1
      fi
      sleep 2
    done
  done <<<"$missing"
}

download_superwhisper_models
unset -f download_superwhisper_models
