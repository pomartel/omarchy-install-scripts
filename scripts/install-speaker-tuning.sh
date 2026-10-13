#!/bin/bash
set -euo pipefail

target=${1:?Usage: bash scripts/install-speaker-tuning.sh lenovo|asus}
case "$target" in
lenovo)
  [[ $(</sys/class/dmi/id/product_family) == 'ThinkPad X1 Carbon Gen 13' ]] || {
    echo 'Speaker tuning requires a ThinkPad X1 Carbon Gen 13.' >&2
    exit 1
  }
  ;;
asus)
  [[ $(</sys/class/dmi/id/product_name) == *UX5406SA* ]] || {
    echo 'Speaker tuning requires a Zenbook S 14 UX5406SA.' >&2
    exit 1
  }
  # The shared XML is specifically for Cirrus speakers, PCI subsystem 1043:1e13.
  speaker_pci=$(readlink -f /sys/class/sound/card*/device | while read -r path; do
    if [[ -r $path/subsystem_vendor && -r $path/subsystem_device ]] &&
      [[ $(<"$path/subsystem_vendor") == 0x1043 && $(<"$path/subsystem_device") == 0x1e13 ]]; then
      echo "$path"
    fi
  done)
  [[ -n $speaker_pci ]] || {
    echo 'The Asus speaker hardware does not match the shared tuning.' >&2
    exit 1
  }
  ;;
*)
  echo "Unknown speaker tuning target: $target" >&2
  exit 1
  ;;
esac

# Pin the converter, rather than changing the sound on every INSTALL run.
revision=9bc7eceea6ae6af4c05e4cea1ea8722ad9240e41 # v2026.10
source_dir="${XDG_DATA_HOME:-$HOME/.local/share}/speaker-tuning/source"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/speaker-tuning"
output_dir="${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/pipewire.conf.d"
prefix="Speaker-$target"
conf="$output_dir/Speaker_${target}_Music_Balanced.conf"
irs="${conf%.conf}.irs"
marker="$state_dir/$target.sha256"
installer=$(readlink -f "${BASH_SOURCE[0]}")
dependencies=(git curl python-numpy python-scipy innoextract lsp-plugins-lv2 calf lilv-tools)

# Local checks only on the completed path: no downloads or audio restart.
if [[ -s $conf && -s $irs && -f $marker ]] &&
  sha256sum --status -c "$marker" && pacman -Q "${dependencies[@]}" >/dev/null 2>&1; then
  exit 0
fi

# Generated per-device files must never replace synced YADM configuration.
for file in "$conf" "$irs"; do
  if yadm -C "$HOME" ls-files --error-unmatch "${file#"$HOME/"}" >/dev/null 2>&1; then
    echo "YADM manages $file; refusing to overwrite it." >&2
    exit 1
  fi
done

# Avoid applying two speaker corrections in series.
if pgrep -x easyeffects >/dev/null ||
  systemctl --user is-enabled --quiet easyeffects.service 2>/dev/null ||
  [[ -s ${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/omarchy-speaker-tuning.conf.d/90-tuning.conf ]]; then
  echo 'Disable the existing EasyEffects/Omarchy speaker tuning before installing this one.' >&2
  exit 1
fi
if [[ -e $conf || -e $irs ]] && [[ ! -f $marker ]]; then
  echo "Unmanaged tuning already exists at $conf or $irs; inspect it before installing." >&2
  exit 1
fi

if ! pacman -Q "${dependencies[@]}" >/dev/null 2>&1; then
  omarchy pkg add "${dependencies[@]}"
fi
mkdir -p "$state_dir" "$(dirname "$source_dir")"
if [[ ! -d $source_dir/.git ]]; then
  git clone --quiet --no-checkout https://github.com/antoinecellerier/speaker-tuning-to-easyeffects.git "$source_dir"
fi
git -C "$source_dir" diff --quiet
git -C "$source_dir" diff --cached --quiet
git -C "$source_dir" checkout --quiet --detach "$revision"
cd "$source_dir"

tuning_args=()
if [[ $target == lenovo ]]; then
  python tools/fetch_driver/get_lenovo_dax_xml.py
else
  # Exact UX5406SA XML shared by its owner; verify contents before conversion.
  # https://github.com/antoinecellerier/speaker-tuning-to-easyeffects/issues/29#issuecomment-5439844469
  xml="$state_dir/SOUNDWIRE_MAN_01FA_FUNC_3556_SUBSYS_1E131043.xml"
  comment=$(mktemp)
  trap 'rm -f "$comment"' EXIT
  curl --fail --silent --show-error --location --retry 3 \
    https://api.github.com/repos/antoinecellerier/speaker-tuning-to-easyeffects/issues/comments/5439844469 \
    -o "$comment"
  python - "$comment" "$xml" <<'PY'
import hashlib
import json
from pathlib import Path
import re
import sys

body = json.loads(Path(sys.argv[1]).read_text())["body"]
blocks = re.findall(r"```(?:xml)?\s*\n(.*?)```", body, re.S)
xml, = [block.strip() + "\n" for block in blocks if "<device_data" in block]
expected = "7ff50507eac3d0f67b4616477befab2e34c037850633b05b247c685d0d89417e"
if hashlib.sha256(xml.encode()).hexdigest() != expected:
    sys.exit("The shared Asus tuning changed; inspect it before installing.")
Path(sys.argv[2]).write_text(xml)
PY
  tuning_args=("$xml" --disable bass-enhancer)
fi

# Music avoids the problematic dynamic leveler reported on UX5406SA.
# WirePlumber attaches the chain only to the detected internal speaker sink.
python dolby_to_pipewire.py "${tuning_args[@]}" --profile music --variant balanced \
  --prefix "$prefix" --output-dir "$output_dir" --force
[[ -s $conf && -s $irs ]]
sha256sum "$conf" "$irs" "$installer" >"$marker"
