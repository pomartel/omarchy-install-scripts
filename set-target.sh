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
