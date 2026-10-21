# Omarchy Install Scripts

This repository automates my machine setup for Omarchy environments.

Run `./apply-migrations.sh` from this directory to apply only the current laptop's
pending migrations. The queues start empty. An empty queue does no setup work.
`bootstrap.sh` is the destructive bootstrap for a fresh machine: it runs all
applicable package and configuration scripts and leaves migration queues unchanged.

Both entry points use the shared runner in `scripts/migrations.sh`: `bootstrap.sh`
uses full execution, while `apply-migrations.sh` uses pending-only execution.

## Queueing migrations

Pass a script path and a mandatory target to `queue-migration.sh`:

```bash
./queue-migration.sh packages/common/typora.sh common
./queue-migration.sh configs/common/configure-printers.sh asus
./queue-migration.sh configs/lenovo/enable-direct-boot.sh lenovo
```

Targets are `lenovo`, `asus`, or `common` (both laptops). Common scripts can
target either laptop or both; laptop-specific scripts can only target their own
laptop. Paths can be absolute or relative to the repository root and must identify
an existing `.sh` fragment directly inside a supported packages/configs subfolder.

Migrations are relative symlinks mirroring the source path, for example
`migrations/asus/packages/common/typora.sh`. Targeting `common` creates separate
links for Lenovo and Asus. Queueing an identical link again does nothing;
conflicting entries are rejected. Links execute the current contents of their
source script, not a historical snapshot.

Commit and push new links to distribute the work. On each laptop, `apply-migrations.sh`
runs common packages, laptop packages, common configs, then laptop configs,
using lexical filename order within each group. Queue prerequisites explicitly;
they are not added automatically.

Each successful script is counted and its link is removed immediately. The first
failure stops installation and keeps the failed and unexecuted links for retry.
Broken or invalid links are rejected and retained. Success means a zero exit status
under strict Bash error handling; stderr output alone is not a failure. If removing
a completed link fails, installation stops and reports the error.

Both successful and failed runs report the successful-script count and elapsed
time, including when zero scripts ran:

```text
3 scripts completed successfully in 12.4s.
Installation failed: 2 scripts completed successfully in 8.1s.
```

Commit and push completed link removals before synchronizing further changes.
Neither command performs Git operations automatically. To run a script again,
queue it again after its previous link has been removed.

## Validation

To validate scripts without applying them, run:

```bash
bash -n path/to/changed-script.sh
shellcheck -s bash path/to/changed-script.sh
shfmt -d path/to/changed-script.sh
```

## Application notes

OmaMarp is installed on both laptops by `packages/common/omamarp.sh`, after the
common Node.js setup. It installs the Qt/build dependencies and builds the latest
commit on the private GitHub repository’s default branch (currently `master`),
using the existing SSH access.
The build checkout lives in `$XDG_CACHE_HOME/omamarp/source` (default
`~/.cache/omamarp/source`), separate from `~/Projects/OmaMarp`. Application files
use `$XDG_DATA_HOME` (default `~/.local/share`). Each execution fetches and rebuilds
the remote default branch, with build output visible. A failed fetch stops the
installation rather than silently using an older commit. YADM
continues to manage shortcuts and file associations;
the installer does not overwrite the editor configuration.

Internal speaker tuning is installed by `configs/common/speaker-tuning.sh`,
using `HOSTNAME` to select the Lenovo or Asus tuning. Queue it for
`./apply-migrations.sh` when needed. To install only the speaker tuning directly, run
from this repository:

```bash
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
audio. Each queued run reapplies the tuning, including when the generated files
already exist. No EasyEffects application or Omarchy tuning wrapper is
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
`systemctl --user restart pipewire pipewire-pulse`. To reinstall the tuning,
queue `configs/common/speaker-tuning.sh` for the appropriate laptop and run `apply-migrations.sh`.
