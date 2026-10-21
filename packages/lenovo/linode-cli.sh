if omarchy-cmd-missing linode-cli; then
  omarchy-pkg-add python-pipx
  pipx install linode-cli
fi
