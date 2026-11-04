# Temporary workaround for stale ChatGPT Desktop connections after suspend.
# Upstream bug: https://github.com/openai/codex/issues/17003
# Codex can reuse a WebSocket that still appears connected after waking, then
# wait for the 300-second idle timeout before reconnecting. Observed on Asus
# with Desktop 26.1029.61003-1; a real sleep/wake cycle validated this workaround
# on 2026-11-04 without restarting ChatGPT or its Codex backend.
#
# The post-sleep hook retires public HTTPS sockets owned by Desktop's Codex
# app-server while systemd still freezes user.slice. Codex then uses its normal
# reconnect path. It leaves the application running and excludes standalone
# CLI processes, remote exec-server processes, and local connections.
# YADM owns ~/bin/chatgpt-reconnect; systemd executes a root-owned copy so the
# privileged hook does not run directly from a user-writable file.
#
# Once the upstream fix is included in the installed Desktop backend and has
# been verified across sleep/wake without this hook, remove the workaround:
# - delete ~/bin/chatgpt-reconnect from YADM;
# - delete this installation script and any pending migration links to it;
# - remove /usr/lib/systemd/system-sleep/90-chatgpt-reconnect from each machine
#   where it was installed (currently Asus). Deleting the source files alone
#   does not remove this installed copy or stop the hook from running.
chatgpt_reconnect_source="$HOME/bin/chatgpt-reconnect"
chatgpt_reconnect_hook=/usr/lib/systemd/system-sleep/90-chatgpt-reconnect

if [[ ! -f $chatgpt_reconnect_source ]]; then
  echo 'Pull YADM to obtain ~/bin/chatgpt-reconnect, then rerun this migration.' >&2
  return 1
fi

if cmp -s "$chatgpt_reconnect_source" "$chatgpt_reconnect_hook" &&
  [[ $(stat -c '%u:%g:%a' "$chatgpt_reconnect_hook") == 0:0:755 ]]; then
  return 0
fi

sudo install -D -m 0755 -o root -g root "$chatgpt_reconnect_source" "$chatgpt_reconnect_hook"
