#!/bin/bash

# If the computer name is omarchy-home, set the INSTALL_TARGET to home. if set to omarchy-school, set to school. Otherwise, exit with an error.
if [ "$HOSTNAME" == "home-omarchy" ]; then
  INSTALL_TARGET="home"
elif [ "$HOSTNAME" == "school-omarchy" ]; then
  INSTALL_TARGET="school"
else
  echo "ERROR: Unknown hostname '$HOSTNAME'. Cannot determine INSTALL_TARGET." >&2
  exit 1
fi
export INSTALL_TARGET

# Verify SSH keys exist in ~/.ssh before proceeding
shopt -s nullglob
ssh_keys=("$HOME/.ssh"/id_*)
if [ ${#ssh_keys[@]} -eq 0 ]; then
  echo "ERROR: No SSH keys found in $HOME/.ssh." >&2
  exit 1
fi

./set-locale.sh
./add-packages.sh

./add-suspend-to-system-menu.sh
./copy-sudoers-rules.sh
./set-power-profile-rule.sh
./clone-git-projects.sh
./remove-default-apps.sh
./set-default-font.sh
./add-suspend-to-system-menu.sh
./configure-hibernation.sh

echo "All install scripts completed."
