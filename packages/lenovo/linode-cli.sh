if omarchy-cmd-missing linode-cli; then
  if omarchy-cmd-missing pipx; then
    omarchy pkg add python-pipx
  fi
  pipx install linode-cli
fi
