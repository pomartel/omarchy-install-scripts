#!/bin/bash

configure_agents_session() {
  local unit="$HOME/.config/systemd/user/agents-session-token.service"
  local helper="$HOME/bin/agents-session-unlock"
  local hook="$HOME/.config/omarchy/hooks/post-boot.d/agents-session-token.sh"
  mkdir -p "$HOME/bin" "$(dirname "$unit")"
  if ! cmp -s scripts/agents-session-unlock "$helper" || [[ ! -x "$helper" ]]; then
    install -m 755 scripts/agents-session-unlock "$helper"
    printf 'Installed Agents session unlock helper.\n'
  fi
  if ! cmp -s scripts/agents-session-token.service "$unit"; then
    install -m 644 scripts/agents-session-token.service "$unit"
    systemctl --user daemon-reload
    printf 'Installed Agents session service.\n'
  fi
  if ! cmp -s scripts/agents-session-token.sh "$hook" || [[ ! -x "$hook" ]]; then
    omarchy hook install post-boot scripts/agents-session-token.sh
  fi
}

configure_agents_session
unset -f configure_agents_session
