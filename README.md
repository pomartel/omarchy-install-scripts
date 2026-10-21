# Omarchy Install Scripts

Package and configuration scripts for my `lenovo` and `asus` laptops.
Shared scripts live in `packages/common/` and `configs/common/`; laptop-specific
scripts use the corresponding `lenovo/` or `asus/` directory.

## Running

Run from the repository root. Both entry points validate `$HOSTNAME` and use
`scripts/migrations.sh`:

- `./apply-migrations.sh`: run only this laptop's pending migrations.
- `./bootstrap.sh`: fresh installation, including a destructive YADM reset,
  followed by all applicable scripts. Migration queues remain unchanged.

Execution order is common packages, laptop packages, common configs, then laptop
configs, with lexical ordering within each group.

Both entry points share a nonblocking repository lock. A concurrent run fails
before changing anything, including before bootstrap resets YADM.

Dropbox symlink setup requires each destination folder to exist. It only replaces
empty local directories and refuses existing files, nonempty directories, or
symlinks pointing elsewhere. Resolve those conflicts manually and rerun the script.

## Migrations

Queue an existing script with an explicit target:

```bash
./queue-migration.sh packages/common/typora.sh common
./queue-migration.sh configs/common/configure-printers.sh asus
./queue-migration.sh configs/lenovo/enable-direct-boot.sh lenovo
```

Targets are `lenovo`, `asus`, or `common` (both). Shared scripts may target either
laptop or both; laptop-specific scripts may only target their own laptop. Paths
may be absolute or repository-relative and must name a `.sh` file directly inside
one of the package/config directories above. Queue prerequisites explicitly.

Each queue entry is a relative symlink mirroring the source path, such as
`migrations/asus/packages/common/typora.sh`. `common` creates an independent link
for each laptop. Identical links are a no-op; conflicting entries are rejected.
Links run the source script's current contents, not a saved version.

Commit and push queued links, then pull and run `./apply-migrations.sh` on the
target laptop. Each successful script is counted and its link removed. The first
execution or removal failure stops the run with a nonzero exit status; failed and
unexecuted links remain for retry. Invalid or broken links are rejected and retained.
Success is determined by exit status, not whether stderr is empty.

Every migration run reports the successful-script count and elapsed time, including
failures and empty queues. Empty queues perform no setup work. Commit and push
consumed link removals before synchronizing further changes. Commands never perform
Git operations automatically. To rerun a completed script, queue it again.

## Validation

Check scripts without executing installation:

```bash
bash -n path/to/script.sh
shellcheck -s bash path/to/script.sh
shfmt -d path/to/script.sh
git diff --check
```

## Application notes

**OmaMarp:** `packages/common/omamarp.sh` fetches and builds the latest default-branch
commit using SSH access. Build dependencies come from Omarchy. Its checkout is
`$XDG_CACHE_HOME/omamarp/source` (default `~/.cache/omamarp/source`), separate from
the development project. YADM manages shortcuts and file associations.

**Speaker tuning:** queue `configs/common/speaker-tuning.sh` for the appropriate
laptop. It applies the Music/Balanced tuning to internal speakers only and briefly
restarts audio. Generated files stay local, outside YADM; the script rejects
YADM-owned files and conflicting EasyEffects/Omarchy tuning. The converter is pinned
to v2026.10, with checksum-verified inputs. Asus uses the UX5406SA tuning from
[device report #29](https://github.com/antoinecellerier/speaker-tuning-to-easyeffects/issues/29#issuecomment-5439844469)
with its extra bass enhancer disabled; listening verification remains necessary.

Inspect the installed tuning:

```bash
python ~/.local/share/speaker-tuning/source/dolby_to_pipewire.py --doctor
```

To undo, remove only `Speaker_lenovo_Music_Balanced.conf` and its matching `.irs`
(or `Speaker_asus_Music_Balanced.conf` and `.irs`) from
`~/.config/pipewire/pipewire.conf.d/`, then run
`systemctl --user restart pipewire pipewire-pulse`. Queue the script again to reinstall.
