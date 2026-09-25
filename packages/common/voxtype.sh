# Voxtype dictation tool
omarchy-pkg-add wtype voxtype-bin

voxtype_onnx=/usr/lib/voxtype/voxtype-onnx-avx2
"$voxtype_onnx" setup --download --model parakeet-tdt-0.6b-v3-int8 --quiet --no-post-install

voxtype_config_changed=false
if [[ $("$voxtype_onnx" config get engine) != parakeet ]]; then
  "$voxtype_onnx" config set engine parakeet
  voxtype_config_changed=true
fi
if [[ $("$voxtype_onnx" config get parakeet.model) != parakeet-tdt-0.6b-v3-int8 ]]; then
  "$voxtype_onnx" config set parakeet.model parakeet-tdt-0.6b-v3-int8
  voxtype_config_changed=true
fi

voxtype_service_override="$HOME/.config/systemd/user/voxtype.service.d/onnx.conf"
if ! printf '[Service]\nExecStart=\nExecStart=%s daemon\n' "$voxtype_onnx" | cmp -s - "$voxtype_service_override"; then
  mkdir -p "$(dirname "$voxtype_service_override")"
  printf '[Service]\nExecStart=\nExecStart=%s daemon\n' "$voxtype_onnx" >"$voxtype_service_override"
  voxtype_config_changed=true
fi

if ! systemctl --user cat voxtype.service >/dev/null 2>&1; then
  voxtype setup systemd
fi

systemctl --user daemon-reload
if ! systemctl --user is-active --quiet voxtype.service; then
  systemctl --user enable --now voxtype.service
elif [[ "$voxtype_config_changed" == true || $(readlink -f "/proc/$(systemctl --user show -P MainPID voxtype.service)/exe") != "$voxtype_onnx" ]]; then
  systemctl --user restart voxtype.service
fi

unset voxtype_onnx voxtype_config_changed voxtype_service_override
