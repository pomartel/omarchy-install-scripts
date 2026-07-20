# DroidCam with iPhone USB support and a persistent virtual webcam
omarchy-pkg-add linux-headers v4l2loopback-dkms usbmuxd
omarchy-pkg-aur-add droidcam

sudo dkms autoinstall -k "$(uname -r)"

echo v4l2loopback | sudo tee /etc/modules-load.d/droidcam.conf > /dev/null
echo 'options v4l2loopback devices=1 video_nr=10 card_label="DroidCam" exclusive_caps=1' |
  sudo tee /etc/modprobe.d/droidcam.conf > /dev/null

if ! lsmod | grep -q '^v4l2loopback '; then
  sudo modprobe v4l2loopback
fi

sudo systemctl start usbmuxd.service

if ! modinfo -k "$(uname -r)" v4l2loopback > /dev/null; then
  echo "ERROR: v4l2loopback was not built for kernel $(uname -r)." >&2
  exit 1
fi
