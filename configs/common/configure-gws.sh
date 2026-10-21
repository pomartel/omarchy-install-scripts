(
  auth_status=$(gws auth status) || exit

  # An expired access token can be refreshed without another browser login.
  if jq -e '.has_refresh_token == true and .encryption_valid == true
    and ((.scopes // []) | index("https://www.googleapis.com/auth/calendar") != null)' \
    <<<"$auth_status" >/dev/null; then
    exit
  fi

  if ! jq -e '.client_config_exists == true' <<<"$auth_status" >/dev/null; then
    echo "Google Calendar: run yadm decrypt to restore ~/.config/gws/client_secret.json, then rerun apply-migrations.sh." >&2
    exit
  fi

  if [[ ! -t 0 ]]; then
    echo "Google Calendar: run gws auth login --services calendar from a terminal to connect your account." >&2
    exit
  fi

  gws auth login --services calendar
)
