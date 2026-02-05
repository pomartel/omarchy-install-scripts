# Underscore (_) in front of the filename to install it first. It's a prerequesite for other node packages
if omarchy-cmd-missing node; then
  omarchy-install-dev-env node
fi
