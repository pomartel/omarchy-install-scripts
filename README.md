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

Brave DevTools MCP is installed on both laptops by `packages/common/brave-mcp.sh`
at version 1.9.0. The server lives in `~/.local/share/brave-devtools-mcp/server`;
its persistent headless browser profile lives alongside it in `profile`.
This is a separate, invisible Brave instance, not the normal desktop browser.
Profile contents (cookies, history, and sessions) remain local to each laptop.

YADM manages `~/bin/brave-devtools-mcp` and the `brave-devtools` MCP entry in both
hostname variants of `~/.codex/config.toml`. The wrapper resolves Node through
mise, so a Node upgrade does not require editing the MCP configuration.
Pull YADM changes before running `./INSTALL.sh` on an existing laptop, then
restart ChatGPT/Codex to load the updated MCP command. The installer preserves
the existing browser profile and skips npm when the pinned version is installed.
