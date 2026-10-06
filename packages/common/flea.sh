# Install Flea and make it the default file manager and file chooser.
if omarchy-pkg-missing flea && omarchy-pkg-missing flea-bin; then
  omarchy pkg add flea
  flea --default
fi
