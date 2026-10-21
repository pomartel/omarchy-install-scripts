# Configure Google Workspace (GWS) authentication for the Calendar plugin.

auth_status=$(gws auth status) || return
gws_auth_ready='.has_refresh_token == true and .encryption_valid == true
  and ((.scopes // []) | index("https://www.googleapis.com/auth/calendar") != null)'

# An expired access token can be refreshed without another browser login.
if jq -e "$gws_auth_ready" <<<"$auth_status" >/dev/null; then
  return 0
fi

if ! jq -e '.client_config_exists == true' <<<"$auth_status" >/dev/null; then
  echo "Google Calendar: run yadm decrypt to restore ~/.config/gws/client_secret.json, then rerun apply-migrations.sh." >&2
  return 1
fi

if [[ ! -t 0 ]]; then
  echo "Google Calendar: run gws auth login --services calendar from a terminal to connect your account." >&2
  return 1
fi

gws auth login --services calendar || return
auth_status=$(gws auth status) || return
if ! jq -e "$gws_auth_ready" <<<"$auth_status" >/dev/null; then
  echo "Google Calendar: authentication is incomplete; the migration remains pending." >&2
  return 1
fi
