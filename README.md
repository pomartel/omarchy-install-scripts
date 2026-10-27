# Omarchy Install Scripts

Package and configuration scripts for my `lenovo` and `asus` laptops.
Shared scripts live in `packages/common/` and `configs/common/`; laptop-specific
scripts use the corresponding `lenovo/` or `asus/` directory.

## Organization

- Root commands provide the user-facing interface.
- `scripts/runner.sh` shares execution, timing, and reporting logic.
- `packages/` and `configs/` contain sourced fragments, grouped by host scope.
- `migrations/lenovo/` and `migrations/asus/` hold pending links for each laptop.

YADM owns shared user configuration and host-specific configuration variants.
Install owns package installation and system setup; it must not overwrite
YADM-managed configuration. Migration links schedule that work for each laptop.

## Running

Run from the repository root. Bootstrap and migration execution validate
`$HOSTNAME` and use `scripts/runner.sh`:

- `./update.sh`: pull with `--ff-only`, then apply pending migrations. A failed
  pull stops the command; an already-up-to-date pull still runs pending migrations.
- `./apply-migrations.sh`: run only this laptop's pending migrations.
- `./bootstrap.sh`: fresh installation, including a destructive YADM reset,
  followed by all applicable scripts. Migration queues remain unchanged.

Execution order is common packages, laptop packages, common configs, then laptop
configs, with lexical ordering within each group.

## Migrations

Queue an existing script with an explicit target:

```bash
./queue-migration.sh packages/common/flea.sh common
./queue-migration.sh configs/common/configure-printers.sh asus
./queue-migration.sh configs/lenovo/enable-direct-boot.sh lenovo
```

Targets are `lenovo`, `asus`, or `common` (both). Shared scripts may target either
laptop or both; laptop-specific scripts may only target their own laptop. Paths
may be absolute or repository-relative and must name a `.sh` file directly inside
one of the package/config directories above. Queue prerequisites explicitly.

Each queue entry is a relative symlink mirroring the source path, such as
`migrations/asus/packages/common/flea.sh`. `common` creates an independent link
for each laptop. Identical links are a no-op; conflicting entries are rejected.
Links run the source script's current contents, not a saved version.
The queue command checks arguments, repository containment, and conflicting entries;
the apply command validates script paths, file types, and laptop scopes before running
any migrations.

Commit and push queued links, then pull and run `./apply-migrations.sh` on the
target laptop. Each successful script is counted and its link removed. The first
execution or removal failure stops the run with a nonzero exit status; failed and
unexecuted links remain for retry. Invalid or broken links are rejected and retained.
Success is determined by exit status, not whether stderr is empty.

Applying migrations automatically commits and pushes the tracked links removed
during that run, including when a later migration fails. Unrelated staged changes
are preserved. Empty queues perform no Git operations. A commit or push failure
makes the command fail and requires manual recovery. `./update.sh` includes this
behavior and may request authentication or sudo access while applying scripts.

## Brave popup windows

`packages/common/wl-relabel.sh` installs the tested wl-relabel version with Cargo.
`configs/common/configure-brave-popups.sh` generates a local Brave Origin desktop
entry that uses `~/bin/brave-origin` for every launch action. Pull YADM first: it
owns that wrapper, `~/.config/wl-relabel/rules.toml`, and the Hyprland popup rule.
Fully quit and reopen Brave after applying these migrations. Existing browser
processes cannot be moved behind the proxy. Reapply the configuration script to
refresh the local desktop entry after changes to Brave's packaged desktop entry.

## Validation

Run `./scripts/check.sh` to check Bash syntax, ShellCheck, shfmt formatting, and
staged/unstaged Git diffs. ShellCheck and shfmt must be installed. The command
checks the root scripts, shared scripts, and package/configuration fragments
without executing installers or following migration links. It does not modify files.
