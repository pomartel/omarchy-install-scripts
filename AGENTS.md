# Repository guidelines

This repository contains the Omarchy installation and configuration scripts for
my Asus and Lenovo laptops.

## Structure

- `packages/common/`: packages installed on both computers
- `packages/asus/` and `packages/lenovo/`: machine-specific packages
- `configs/common/`: configuration applied to both computers
- `configs/asus/` and `configs/lenovo/`: machine-specific configuration
- `apply-migrations.sh`: runs only pending migrations for the current laptop
- `queue-migration.sh PATH TARGET`: queues a fragment for the mandatory target
  `lenovo`, `asus`, or `common` (both laptops)
- `migrations/lenovo/` and `migrations/asus/`: relative symlink queues mirroring
  source paths under packages/configs; successful links are removed individually
- `bootstrap.sh`: destructive fresh-machine bootstrap; it is intentionally
  exempt from the normal idempotence requirement

Use Bash's `HOSTNAME` directly to select laptop-specific scripts and queues.
The shared helper in `scripts/migrations.sh` validates that it is `lenovo` or
`asus`; entry points and fragment runners call it before doing setup work.
This helper also owns strict Bash mode, error reporting, script selection, and
execution. Both entry points call `install_run` with `--pending` or `--all`.
Keep `packages/add-packages.sh` and `configs/apply-configs.sh` as thin wrappers
for running one group. Use Omarchy's own package checks and installers directly;
do not override them with local wrappers or package caches.

Queue common fragments for either laptop or both; laptop-specific fragments may
only target their matching laptop. Queue prerequisites explicitly. Duplicate
links are a no-op; conflicting, invalid, or broken entries must not be overwritten
or silently removed. `apply-migrations.sh` stops at the first failure and always reports the
successful-script count and elapsed time. `bootstrap.sh` runs all applicable scripts
without consuming migrations. The fragment runners default to full execution and
also support `--pending`.

Commit and push queued links and successful removals through the normal Git
workflow. Installation and queue commands must not perform Git operations.

Whenever adding or modifying a package or configuration fragment, also run
`./queue-migration.sh PATH TARGET` for that script. Use `common` for scripts in
`packages/common/` or `configs/common/`, and the matching `lenovo` or `asus`
target for laptop-specific scripts. If the user explicitly limits a common
script's rollout to one laptop, use that laptop as the target instead. Include
the migration links in the same commit as the script change; an identical
already-pending link satisfies this requirement.

## Script conventions

Run the entry-point scripts from the repository root.

Package and configuration fragments are sourced in lexical filename order,
with common scripts running before target-specific scripts. They inherit Bash,
`set -euo pipefail`, variables, functions, and traps from their runner. Keep
their variables and functions narrowly scoped, and unset helper functions after
use. A filename beginning with `_` may be used when a prerequisite must run
first.

Keep one concern per script and preserve the existing directory organization
and simple Bash style.
Do not define functions that are called only once. Inline that code without
variable cleanup or parenthesized subshell wrappers; the collision risk is low.
Use `return` for early exits from sourced fragments. Restore the working directory
after changing it, and do not replace the runner's traps.
Keep functions for logic reused by multiple callers or repeated operations.

Use Omarchy commands for package and service installation whenever an
appropriate command exists. Call the direct dashed commands (for example,
`omarchy-pkg-add` and `omarchy-plugin-add`), not the `omarchy` dispatcher.

Before adding a file or file-writing step, check whether the target file is
already tracked by YADM. Do not recreate, overwrite, or duplicate files that
YADM manages; let YADM remain the source of truth for those configurations.

Except for `bootstrap.sh`, scripts must be safe to run repeatedly. The migration
queue decides when they run; do not add guards merely to improve no-op speed or
suppress normal command output. Prefer directly calling idempotent commands
such as Omarchy package installers, systemctl enable/start, and settings setters.
Keep guards needed to preserve user data/settings, prevent duplicate creation,
avoid repeated authentication or toggles, and handle missing prerequisites.
Keep errors and useful command output visible. An empty migration queue should
still do no setup work and only print the completion summary.

Do not add destructive behavior or broaden existing deletion/reset operations
without explicit instruction.

## Validation

Automated tests are not necessary for this personal installation repository.
Do not add, maintain, or run a test suite unless explicitly requested.

After changing shell scripts, run `bash -n` on the affected files and use
`shellcheck` and `shfmt` when practical. Do not run the installation entry
points solely as a test because they modify the current machine.

Favor simple, readable code. This is a personal project, so do not add
complexity for unsupported machines or hypothetical edge cases.

## Delivery

Always commit and push completed changes, then provide a link to the GitHub
commit page.
