# Repository guidelines

This repository contains the Omarchy installation and configuration scripts for
my Asus and Lenovo laptops.

## Structure

- `packages/common/`: packages installed on both computers
- `packages/asus/` and `packages/lenovo/`: machine-specific packages
- `configs/common/`: configuration applied to both computers
- `configs/asus/` and `configs/lenovo/`: machine-specific configuration
- `INSTALL.sh`: repeatable package and configuration update
- `NEW-INSTALL.sh`: destructive fresh-machine bootstrap; it is intentionally
  exempt from the normal idempotence requirement

`set-target.sh` maps the `lenovo-omarchy` and `asus-omarchy` hostnames to their
corresponding target directories.

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

Except for `NEW-INSTALL.sh`, scripts must be safe to run repeatedly. Avoid
printing success messages when an individual operation makes no change.
Warnings, errors, actions that actually changed state, and the top-level
completion summary may be printed.

Do not add destructive behavior or broaden existing deletion/reset operations
without explicit instruction.

## Validation

After changing shell scripts, run `bash -n` on the affected files and use
`shellcheck` and `shfmt` when practical. Do not run the installation entry
points solely as a test because they modify the current machine.

Favor simple, readable code. This is a personal project, so do not add
complexity for unsupported machines or hypothetical edge cases.

## Delivery

Always commit and push completed changes, then provide a link to the GitHub
commit page.
