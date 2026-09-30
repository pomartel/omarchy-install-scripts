# Voxtype dictation tool
omarchy-pkg-add wtype voxtype-bin

# YADM provides the Parakeet config and ONNX systemd override.
voxtype_model_dir="${XDG_DATA_HOME:-$HOME/.local/share}/voxtype/models/parakeet-tdt-0.6b-v3-int8"
if [[ ! -s "$voxtype_model_dir/encoder-model.int8.onnx" ||
  ! -s "$voxtype_model_dir/decoder_joint-model.int8.onnx" ||
  ! -s "$voxtype_model_dir/config.json" || ! -s "$voxtype_model_dir/vocab.txt" ]]; then
  /usr/lib/voxtype/voxtype-onnx-avx2 setup --download --model parakeet-tdt-0.6b-v3-int8 --quiet --no-post-install
fi
unset voxtype_model_dir

if ! systemctl --user is-active --quiet voxtype.service; then
  if ! systemctl --user cat voxtype.service >/dev/null 2>&1; then
    voxtype setup systemd
  fi
  systemctl --user daemon-reload
  systemctl --user enable --now voxtype.service
fi
