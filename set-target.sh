if [[ $HOSTNAME != lenovo && $HOSTNAME != asus ]]; then
  echo "ERROR: Unknown hostname '$HOSTNAME'. Cannot determine INSTALL_TARGET." >&2
  exit 1
fi
export INSTALL_TARGET="$HOSTNAME"
