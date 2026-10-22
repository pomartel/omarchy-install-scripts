#!/bin/bash
# Sourced by the runner, which enables errexit.
# shellcheck disable=SC2164

case "$HOSTNAME" in
lenovo) [[ $(</sys/class/dmi/id/product_family) == 'ThinkPad X1 Carbon Gen 13' ]] ;;
asus) [[ $(</sys/class/dmi/id/product_name) == *UX5406SA* ]] ;;
*) return 1 ;;
esac

source_dir="${XDG_DATA_HOME:-$HOME/.local/share}/speaker-tuning/source"
output_dir="${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/pipewire.conf.d"

for file in "$output_dir/Speaker_${HOSTNAME}_Music_Balanced."{conf,irs}; do
  if yadm -C "$HOME" ls-files --error-unmatch "${file#"$HOME/"}" >/dev/null 2>&1; then
    echo "YADM manages $file; refusing to overwrite it." >&2
    return 1
  fi
done
if pgrep -x easyeffects >/dev/null ||
  systemctl --user is-enabled --quiet easyeffects.service 2>/dev/null ||
  [[ -s ${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/omarchy-speaker-tuning.conf.d/90-tuning.conf ]]; then
  echo 'Disable the existing EasyEffects/Omarchy speaker tuning first.' >&2
  return 1
fi

omarchy-pkg-add git curl python-numpy python-scipy innoextract lsp-plugins-lv2 calf lilv-tools
if [[ ! -d $source_dir ]]; then
  mkdir -p "$(dirname "$source_dir")"
  git clone --quiet --depth 1 --branch v2026.10 \
    https://github.com/antoinecellerier/speaker-tuning-to-easyeffects.git "$source_dir"
fi
speaker_tuning_cwd=$PWD
cd "$source_dir"
[[ $(git rev-parse HEAD) == 9bc7eceea6ae6af4c05e4cea1ea8722ad9240e41 ]]

tuning_args=()
if [[ $HOSTNAME == lenovo ]]; then
  python tools/fetch_driver/get_lenovo_dax_xml.py
else
  # Exact UX5406SA tuning shared in device report #29; music avoids its leveler issue.
  # https://github.com/antoinecellerier/speaker-tuning-to-easyeffects/issues/29#issuecomment-5439844469
  # Python's regex contains literal Markdown backticks.
  # shellcheck disable=SC2016
  curl -fsSL --retry 3 \
    https://api.github.com/repos/antoinecellerier/speaker-tuning-to-easyeffects/issues/comments/5439844469 |
    python -c '
import hashlib
import json
from pathlib import Path
import re
import sys

body = json.load(sys.stdin)["body"]
xml, = [block.strip() + "\n" for block in re.findall(r"```xml\s*\n(.*?)```", body, re.S)]
expected = "7ff50507eac3d0f67b4616477befab2e34c037850633b05b247c685d0d89417e"
if hashlib.sha256(xml.encode()).hexdigest() != expected:
    sys.exit("The shared Asus tuning changed; inspect it before installing.")
Path(sys.argv[1]).write_text(xml)
' "$source_dir/SOUNDWIRE_MAN_01FA_FUNC_3556_SUBSYS_1E131043.xml"
  # Let the converter match the XML to the Asus audio hardware.
  tuning_args=(--windows "$source_dir" --disable bass-enhancer)
fi

# The smart filter applies only to internal speakers, bypassing other outputs.
python dolby_to_pipewire.py "${tuning_args[@]}" --profile music --variant balanced \
  --prefix "Speaker-$HOSTNAME" --output-dir "$output_dir" --force
cd "$speaker_tuning_cwd"
