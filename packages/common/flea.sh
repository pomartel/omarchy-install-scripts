# Install Flea and make it the default file manager and file chooser.
if omarchy-pkg-missing flea-bin; then
  if omarchy-pkg-missing flea; then
    omarchy pkg aur add flea-bin
  else
    # Replace the conflicting repository package in the same transaction.
    yay -S --needed --noconfirm --useask flea-bin
    refresh_install_packages
  fi
  flea --default
fi
