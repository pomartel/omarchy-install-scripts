# Retire stale ChatGPT Desktop connections after suspend (openai/codex#17003).
# YADM owns the source; systemd must execute a root-owned installed copy.
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
