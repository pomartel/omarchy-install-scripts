# Install Flea and make it the default file manager and file chooser.
if omarchy-pkg-missing flea-bin; then
  omarchy pkg aur add flea-bin && flea --default
fi
