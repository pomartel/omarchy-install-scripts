# Install Hex with the portable French dictation preferences owned by YADM.
omarchy-pkg-add hex-bin wtype wl-clipboard

# YADM owns the portable settings, vocabulary, keybindings and adapters.
if hex status --json >/dev/null 2>&1; then
  hex quit --json
fi
"$HOME/bin/yadm/yadm-json-preferences" apply

# With Hex stopped, installation waits for the verified download before returning.
hex model install orukeet --language fr
hex start --json
hex launch-at-login on --json
hex_ready=false
for ((hex_attempt = 0; hex_attempt < 30; hex_attempt++)); do
  if hex status --json | python -c 'import json, sys; s=json.load(sys.stdin); sys.exit(not (s["permissions"]["ready"] and s["listener"]["running"]))'; then
    hex_ready=true
    break
  fi
  sleep 1
done
if [[ $hex_ready != true ]]; then
  printf 'Finish Hex setup in its window, then run this migration again.\n' >&2
  hex window show
  return 1
fi
unset hex_ready hex_attempt

hyprctl reload
if [[ -n $(hyprctl configerrors) ]]; then
  hyprctl configerrors >&2
  return 1
fi
