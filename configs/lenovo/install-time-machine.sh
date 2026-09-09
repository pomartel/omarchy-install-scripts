#!/bin/bash

plugin_id="jankeesvw.time-machine"
plugin_url="https://github.com/jankeesvw/omarchy-time-machine.git"
plugins=$(omarchy plugin list --json)

if jq -e --arg id "$plugin_id" 'any(.[]; .id == $id)' <<<"$plugins" >/dev/null; then
  if ! jq -e --arg id "$plugin_id" 'any(.[]; .id == $id and .enabled)' <<<"$plugins" >/dev/null; then
    omarchy plugin enable "$plugin_id"
  fi
else
  omarchy plugin add "$plugin_url" --enable --yes
fi

if ! jq -e --arg id "$plugin_id" +  '.bar.layout.right | any(.[]; .id == $id)' +  ~/.config/omarchy/shell.json >/dev/null; then
  omarchy bar move "$plugin_id" --section right
fi
