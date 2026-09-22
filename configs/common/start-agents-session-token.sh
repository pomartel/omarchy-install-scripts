#!/bin/bash

start_agents_session_token() {
  local service=agents-session-token.service
  systemctl --user daemon-reload
  if ! systemctl --user is-active --quiet "$service"; then
    systemctl --user start "$service"
    echo "Started $service"
  fi
}

start_agents_session_token
unset -f start_agents_session_token
