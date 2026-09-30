if omarchy-cmd-missing tailscale; then
  omarchy install service tailscale
fi

tailscale_prefs=$(tailscale debug prefs)
if ! jq -e '.RunSSH == true' <<<"$tailscale_prefs" >/dev/null; then
  tailscale set --ssh
fi
unset tailscale_prefs
