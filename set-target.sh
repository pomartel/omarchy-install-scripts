# If the computer name is lenovo-omarchy, set INSTALL_TARGET to lenovo. If set to asus-omarchy, set it to asus. Otherwise, exit with an error.
if [ "$HOSTNAME" == "lenovo-omarchy" ]; then
  INSTALL_TARGET="lenovo"
elif [ "$HOSTNAME" == "asus-omarchy" ]; then
  INSTALL_TARGET="asus"
else
  echo "ERROR: Unknown hostname '$HOSTNAME'. Cannot determine INSTALL_TARGET." >&2
  exit 1
fi
export INSTALL_TARGET
