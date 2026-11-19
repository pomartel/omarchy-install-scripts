# Uninstall the former dictation backend only after its replacement is ready.
if omarchy-pkg-present superwhisper-bin; then
  if ! hex status --json | python -c 'import json, sys; s=json.load(sys.stdin); sys.exit(not (s["permissions"]["ready"] and s["listener"]["running"]))'; then
    printf 'Install and finish configuring Hex before removing Superwhisper.\n' >&2
    return 1
  fi
  systemctl --user disable --now superwhisper.service
  omarchy-pkg-drop superwhisper-bin
fi

# Remove only setup-user links. Preserve settings, history and downloaded models.
for superwhisper_old_link in \
  "$HOME/.local/bin/superwhisper" \
  "$HOME/.config/omarchy/plugins/superwhisper-panel" \
  "$HOME/.agents/skills/superwhisper" \
  "$HOME/.codex/skills/superwhisper"; do
  if [[ -L $superwhisper_old_link ]]; then
    case $(readlink -- "$superwhisper_old_link") in
    /usr/bin/superwhisper | /opt/superwhisper/*) rm -- "$superwhisper_old_link" ;;
    esac
  fi
done
unset superwhisper_old_link

omarchy-restart-shell
