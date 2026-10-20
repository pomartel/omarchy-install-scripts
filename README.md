# Omarchy Install Scripts

This repository automates my machine setup for Omarchy environments.

Run `./INSTALL.sh` from this directory to apply common scripts followed by
the current laptop's scripts. Both runners stop on errors; the completion
summary appears only after all scripts succeed. `NEW-INSTALL.sh` is the
destructive bootstrap for a fresh machine.

Repeated runs skip installed packages, configured plugins, existing Google
credentials, matching configuration files, and downloaded Voxtype models.

To validate scripts without applying them, run:

```bash
bash -n path/to/changed-script.sh
shellcheck -s bash path/to/changed-script.sh
shfmt -d path/to/changed-script.sh
```

OmaMarp is installed on both laptops by `packages/common/omamarp.sh`, after the
common Node.js setup. It installs the Qt/build dependencies and builds the latest
commit on the private GitHub repository’s default branch (currently `master`),
using the existing SSH access.
The build checkout lives in `$XDG_CACHE_HOME/omamarp/source` (default
`~/.cache/omamarp/source`), separate from `~/Projects/OmaMarp`. Application files
use `$XDG_DATA_HOME` (default `~/.local/share`). Matching installed revisions are
skipped after fetching the remote default branch. Each run checks GitHub; a failed
fetch stops the installation rather than silently using an older commit. YADM
continues to manage shortcuts and file associations;
the installer does not overwrite the editor configuration.

Internal speaker tuning is installed by `configs/common/speaker-tuning.sh`,
using `INSTALL_TARGET` to select the Lenovo or Asus tuning. It runs through
`./INSTALL.sh`. To install only the speaker tuning, run from this repository:

```bash
source ./set-target.sh
source ./configs/common/speaker-tuning.sh
```

The converter is pinned to v2026.10. Lenovo's checksum-verified driver is fetched
from its update catalog. Asus uses the exact UX5406SA XML shared in
[device report #29](https://github.com/antoinecellerier/speaker-tuning-to-easyeffects/issues/29#issuecomment-5439844469),
with its contents verified by SHA-256. The Asus Music profile disables the extra
bass enhancer, following that report's bass/resonance concerns. Its sound still
needs listening verification on this laptop.

The Music/Balanced tuning loads with PipeWire and attaches only to the internal
speakers; USB, HDMI and Bluetooth outputs bypass it. Installation briefly restarts
audio. Repeat runs skip setup when the configuration, impulse response and packages
are already present. No EasyEffects application or Omarchy tuning wrapper is
installed. Generated files stay local to each machine and must not be added to
YADM. The installer refuses to overwrite YADM-managed tuning files or stack with
an active EasyEffects/Omarchy speaker tuning.

To inspect the installed chain:

```bash
python ~/.local/share/speaker-tuning/source/dolby_to_pipewire.py --doctor
```

To undo, remove only `Speaker_lenovo_Music_Balanced.conf` and its matching `.irs`
(or `Speaker_asus_Music_Balanced.conf` and `.irs`) from
`~/.config/pipewire/pipewire.conf.d/`, then run
`systemctl --user restart pipewire pipewire-pulse`. Running `INSTALL.sh` again will reinstall the tuning.
