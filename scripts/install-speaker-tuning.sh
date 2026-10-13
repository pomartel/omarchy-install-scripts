#!/bin/bash
set -euo pipefail

target=${1:?Usage: bash scripts/install-speaker-tuning.sh lenovo|asus}
case "$target" in
lenovo) [[ $(</sys/class/dmi/id/product_family) == 'ThinkPad X1 Carbon Gen 13' ]] ;;
asus) [[ $(</sys/class/dmi/id/product_name) == *UX5406SA* ]] ;;
*) exit 1 ;;
esac

source_dir="${XDG_DATA_HOME:-$HOME/.local/share}/speaker-tuning/source"
output_dir="${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/pipewire.conf.d"
conf="$output_dir/Speaker_${target}_Music_Balanced.conf"
irs="${conf%.conf}.irs"
packages=(git curl python-numpy python-scipy innoextract lsp-plugins-lv2 calf lilv-tools)

# Completed installations need no network access or audio restart.
if [[ -s $conf && -s $irs ]] && pacman -Q "${packages[@]}" >/dev/null 2>&1; then
  exit 0
fi
for file in "$conf" "$irs"; do
  if yadm -C "$HOME" ls-files --error-unmatch "${file#"$HOME/"}" >/dev/null 2>&1; then
    echo "YADM manages $file; refusing to overwrite it." >&2
    exit 1
  fi
done
if pgrep -x easyeffects >/dev/null ||
  systemctl --user is-enabled --quiet easyeffects.service 2>/dev/null ||
  [[ -s ${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/omarchy-speaker-tuning.conf.d/90-tuning.conf ]]; then
  echo 'Disable the existing EasyEffects/Omarchy speaker tuning first.' >&2
  exit 1
fi

if ! pacman -Q "${packages[@]}" >/dev/null 2>&1; then
  omarchy pkg add "${packages[@]}"
fi
if [[ ! -d $source_dir ]]; then
  mkdir -p "$(dirname "$source_dir")"
  git clone --quiet --depth 1 --branch v2026.10 \
    https://github.com/antoinecellerier/speaker-tuning-to-easyeffects.git "$source_dir"
fi
cd "$source_dir"
[[ $(git rev-parse HEAD) == 9bc7eceea6ae6af4c05e4cea1ea8722ad9240e41 ]]

tuning_args=()
if [[ $target == lenovo ]]; then
  python tools/fetch_driver/get_lenovo_dax_xml.py
else
  # Exact UX5406SA tuning shared in device report #29; music avoids its leveler issue.
  # https://github.com/antoinecellerier/speaker-tuning-to-easyeffects/issues/29#issuecomment-5439844469
  xml="$source_dir/SOUNDWIRE_MAN_01FA_FUNC_3556_SUBSYS_1E131043.xml"
  comment=$(mktemp)
  trap 'rm -f "$comment"' EXIT
  curl -fsSL --retry 3 \
    https://api.github.com/repos/antoinecellerier/speaker-tuning-to-easyeffects/issues/comments/5439844469 \
    -o "$comment"
  python - "$comment" "$xml" <<'PY'
import hashlib
import json
from pathlib import Path
import re
import sys

body = json.loads(Path(sys.argv[1]).read_text())["body"]
xml, = [block.strip() + "\n" for block in re.findall(r"```xml\s*\n(.*?)```", body, re.S)]
expected = "7ff50507eac3d0f67b4616477befab2e34c037850633b05b247c685d0d89417e"
if hashlib.sha256(xml.encode()).hexdigest() != expected:
    sys.exit("The shared Asus tuning changed; inspect it before installing.")
Path(sys.argv[2]).write_text(xml)
PY
  # Let the converter match the XML to the Asus audio hardware.
  tuning_args=(--windows "$source_dir" --disable bass-enhancer)
fi

# The smart filter applies only to internal speakers, bypassing other outputs.
python dolby_to_pipewire.py "${tuning_args[@]}" --profile music --variant balanced \
  --prefix "Speaker-$target" --output-dir "$output_dir" --force
