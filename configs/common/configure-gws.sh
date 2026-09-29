configure_gws_calendar() {
  local auth_status
  # Keep auth warnings/errors visible, but omit the routine backend announcement.
  auth_status=$(gws auth status 2> >(sed '/^Using keyring backend: /d' >&2)) || return

  # An expired access token can be refreshed without another browser login.
  if jq -e '.has_refresh_token == true and .encryption_valid == true
    and ((.scopes // []) | index("https://www.googleapis.com/auth/calendar") != null)' \
    <<<"$auth_status" >/dev/null; then
    return
  fi

  if ! jq -e '.client_config_exists == true' <<<"$auth_status" >/dev/null; then
    echo "Google Calendar: run yadm decrypt to restore ~/.config/gws/client_secret.json, then rerun INSTALL.sh." >&2
    return
  fi

  if [[ ! -t 0 ]]; then
    echo "Google Calendar: run gws auth login --services calendar from a terminal to connect your account." >&2
    return
  fi

  gws auth login --services calendar
}

configure_gws_calendar
unset -f configure_gws_calendar
