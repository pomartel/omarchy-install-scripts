omarchy-pkg-add hex-bin wtype wl-clipboard

# Stop Hex so model installation waits for the download. Exit 3 means already stopped.
hex quit || [[ $? -eq 3 ]]
systemctl --user stop hex.service
hex model install orukeet --language fr
hex start
hex launch-at-login on

for ((hex_attempt = 0; hex_attempt < 30; hex_attempt++)); do
  if hex status --json | jq -e '.permissions.ready and .listener.running' >/dev/null; then
    return 0
  fi
  sleep 1
done
printf 'Finish Hex setup in its window, then run this migration again.\n' >&2
hex window show
return 1
