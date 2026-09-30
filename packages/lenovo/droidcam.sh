# DroidCam with iPhone USB support and a persistent virtual webcam
omarchy-pkg-add linux-headers v4l2loopback-dkms usbmuxd
omarchy-pkg-aur-add droidcam

droidcam_module='v4l2loopback'
droidcam_options='options v4l2loopback devices=1 video_nr=10 card_label="DroidCam" exclusive_caps=1'
if ! cmp -s <(printf '%s\n' "$droidcam_module") /etc/modules-load.d/droidcam.conf; then
  printf '%s\n' "$droidcam_module" | sudo tee /etc/modules-load.d/droidcam.conf >/dev/null
fi
if ! cmp -s <(printf '%s\n' "$droidcam_options") /etc/modprobe.d/droidcam.conf; then
  printf '%s\n' "$droidcam_options" | sudo tee /etc/modprobe.d/droidcam.conf >/dev/null
fi

if [[ ! -d /sys/module/v4l2loopback ]]; then
  sudo modprobe v4l2loopback
fi

if ! systemctl is-active --quiet usbmuxd.service; then
  sudo systemctl start usbmuxd.service
fi

if ! modinfo -k "$(uname -r)" v4l2loopback >/dev/null; then
  echo "ERROR: v4l2loopback was not built for kernel $(uname -r)." >&2
  exit 1
fi
unset droidcam_module droidcam_options
