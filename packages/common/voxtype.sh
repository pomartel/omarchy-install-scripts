# Voxtype dictation tool
omarchy-pkg-add wtype voxtype-bin

# YADM provides the Parakeet config and ONNX systemd override.
/usr/lib/voxtype/voxtype-onnx-avx2 setup --download --model parakeet-tdt-0.6b-v3-int8 --quiet --no-post-install

if ! systemctl --user is-active --quiet voxtype.service; then
  if ! systemctl --user cat voxtype.service >/dev/null 2>&1; then
    voxtype setup systemd
  fi
  systemctl --user daemon-reload
  systemctl --user enable --now voxtype.service
fi
