configure_gws_calendar() {
  local gws_config_dir="${GOOGLE_WORKSPACE_CLI_CONFIG_DIR:-$HOME/.config/gws}"
  local auth_status

  # Existing credentials are enough for installation; gws refreshes tokens
  # when used. Diagnose or reconnect an existing account manually if needed.
  if [[ -s "$gws_config_dir/credentials.enc" || -s "$gws_config_dir/credentials.json" ]]; then
    return
  fi

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
