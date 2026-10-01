install_omarchy_plugins() {
  local plugins shell_config
  plugins=$(omarchy plugin list --json) || return
  shell_config=$(omarchy-shell shell listShellConfig) || return

  ensure_omarchy_plugin() {
    local plugin_id="$1"
    local repository="$2"
    local plugin_url="https://github.com/$repository.git"

    if jq -e --arg id "$plugin_id" 'any(.[]; .id == $id)' <<<"$plugins" >/dev/null; then
      if ! jq -e --arg id "$plugin_id" \
        'any(.[]; .id == $id and .enabled)' <<<"$plugins" >/dev/null; then
        # Tray widgets can be loaded via plugins[] without sitting directly on
        # the bar, so plugin list reports them as disabled even when configured.
        if ! jq -e --arg id "$plugin_id" '
        any(.plugins[]?; .id == $id)
        and ((.disabledPlugins // []) | index($id) == null)
      ' <<<"$shell_config" >/dev/null; then
          omarchy plugin enable "$plugin_id" || return
          plugins=$(omarchy plugin list --json) || return
          shell_config=$(omarchy-shell shell listShellConfig) || return
        fi
      fi
    else
      omarchy plugin add "$plugin_url" --enable --yes || return
      plugins=$(omarchy plugin list --json) || return
      shell_config=$(omarchy-shell shell listShellConfig) || return
    fi
  }

  ensure_omarchy_plugin "pomartel.omacal" "pomartel/omacal"
  ensure_omarchy_plugin "pomartel.omatasks" "pomartel/omatasks"
  # Remove the retired plugin; keep upstream OmaTasks installed but off the bar.
  if jq -e 'any(.[]; .id == "omarchy-todoist")' <<<"$plugins" >/dev/null; then
    omarchy plugin remove "omarchy-todoist" --yes || return
    plugins=$(omarchy plugin list --json) || return
    shell_config=$(omarchy-shell shell listShellConfig) || return
  fi
  if jq -e 'any(.[]; .id == "crmne.todoist" and .enabled)' <<<"$plugins" >/dev/null; then
    omarchy plugin disable "crmne.todoist" || return
    plugins=$(omarchy plugin list --json) || return
    shell_config=$(omarchy-shell shell listShellConfig) || return
  fi
  ensure_omarchy_plugin "qs-yadm" "pomartel/qs-yadm"
  ensure_omarchy_plugin "crmne.active-window" "crmne/omarchy-active-window"
  ensure_omarchy_plugin "crmne.hyprmoncfg" "crmne/omarchy-hyprmoncfg"
  ensure_omarchy_plugin "io.github.tyrichards.tray" "TyRichards/omarchy-tray"

  if [ "$INSTALL_TARGET" = "lenovo" ]; then
    ensure_omarchy_plugin "jankeesvw.time-machine" "jankeesvw/omarchy-time-machine"
    ensure_omarchy_plugin "keyboard-backlight" "pomartel/keyboard-backlight"
  fi

  unset -f ensure_omarchy_plugin
}

install_omarchy_plugins
unset -f install_omarchy_plugins
