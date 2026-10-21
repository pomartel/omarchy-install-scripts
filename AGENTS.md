# Repository guidelines

This repository contains the Omarchy installation and configuration scripts for
my Asus and Lenovo laptops.

## Structure

- `packages/common/`: packages installed on both computers
- `packages/asus/` and `packages/lenovo/`: machine-specific packages
- `configs/common/`: configuration applied to both computers
- `configs/asus/` and `configs/lenovo/`: machine-specific configuration
- `INSTALL.sh`: runs only pending migrations for the current laptop
- `queue-migration.sh PATH TARGET`: queues a fragment for the mandatory target
  `lenovo`, `asus`, or `common` (both laptops)
- `migrations/lenovo/` and `migrations/asus/`: relative symlink queues mirroring
  source paths under packages/configs; successful links are removed individually
- `NEW-INSTALL.sh`: destructive fresh-machine bootstrap; it is intentionally
  exempt from the normal idempotence requirement

`set-target.sh` maps the `lenovo` and `asus` hostnames to their
corresponding target directories.

Queue common fragments for either laptop or both; laptop-specific fragments may
only target their matching laptop. Queue prerequisites explicitly. Duplicate
links are a no-op; conflicting, invalid, or broken entries must not be overwritten
or silently removed. INSTALL stops at the first failure and always reports the
successful-script count and elapsed time. NEW-INSTALL runs all applicable scripts
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

Use Omarchy commands for package and service installation whenever an
appropriate command exists.

Before adding a file or file-writing step, check whether the target file is
already tracked by YADM. Do not recreate, overwrite, or duplicate files that
YADM manages; let YADM remain the source of truth for those configurations.

Except for `NEW-INSTALL.sh`, scripts must be safe to run repeatedly. Avoid
printing success messages when an individual operation makes no change.
Warnings, errors, actions that actually changed state, and the top-level
completion summary may be printed.

Runs with nothing new to install or configure must be fast as well as quiet.
Use cheap local checks to skip completed work before invoking slower commands.
Do not perform routine authentication checks, network requests, or other
expensive validation for already installed and configured software; reserve
those checks for initial setup, necessary changes, or explicit troubleshooting.

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
