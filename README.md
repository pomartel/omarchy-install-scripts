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

Lenovo's fingerprint resume and retry workaround is documented in
[configs/lenovo/fingerprint-recovery/README.md](configs/lenovo/fingerprint-recovery/README.md).

OmaMarp is installed on both laptops by `packages/common/omamarp.sh`, after the
common Node.js setup. It installs the Qt/build dependencies and builds a pinned
revision from the private GitHub repository using the existing SSH access.
The build checkout lives in `$XDG_CACHE_HOME/omamarp/source` (default
`~/.cache/omamarp/source`), separate from `~/Projects/OmaMarp`. Application files
use `$XDG_DATA_HOME` (default `~/.local/share`). Matching installed revisions are
skipped without a network request. To distribute an OmaMarp update, change the
`revision` in this script. YADM continues to manage shortcuts and file associations;
the installer does not overwrite the editor configuration.
