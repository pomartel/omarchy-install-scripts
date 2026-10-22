# Repository guidelines

Personal Omarchy setup for `lenovo` and `asus`. Keep code simple and preserve
the existing layout. See [README.md](README.md) for usage and migration behavior.

## Structure and execution

- `packages/{common,lenovo,asus}/`: package scripts.
- `configs/{common,lenovo,asus}/`: configuration scripts.
- `bootstrap.sh`: destructive fresh installation; runs all applicable scripts.
- `apply-migrations.sh`: runs pending scripts from `migrations/$HOSTNAME/`.
- `queue-migration.sh PATH TARGET`: schedules scripts using relative symlinks.
- `update.sh`: pulls with `--ff-only`, then applies pending migrations.
- `scripts/check.sh`: runs static validation without executing installers.

Keep user-facing commands at the root and shared execution logic in `scripts/runner.sh`.
Run from the repository root and validate Bash's `HOSTNAME` as `lenovo` or
`asus`. Execute common packages, laptop packages, common configs, then laptop
configs, in lexical order within each group. Use a leading `_` for prerequisites.

## Migrations

When adding or changing a package/config script, queue it unless the user asks
otherwise. Do not queue a migration when a modification leaves what is installed
or configured unchanged, such as refactoring, formatting, or comment changes.
Use `common` for shared scripts and the matching laptop for specific
scripts; honor requests to limit a shared script to one laptop. Queue prerequisites
explicitly and include links in the same commit. An identical pending link suffices.

Reject conflicting, broken, or invalid links without overwriting or deleting them.
Count successful scripts before removing their links. Stop on execution or removal
failure, preserve remaining links, and report the successful count and elapsed time
even on failure or an empty queue. Bootstrap must leave queues unchanged.
The pending-migration runner must commit and push only links successfully removed
during that run, including when a later migration fails. Preserve unrelated staged
changes and report Git failures with a nonzero exit status. Empty queues perform
no Git operations.

## Bash conventions

Fragments are sourced and inherit strict Bash mode, variables, functions, and traps.

- Keep one concern per script. Use functions only for reused logic.
- Avoid unnecessary subshells and variable cleanup; unset helper functions after use.
- Use `return` for early exits, restore the working directory after changing it,
  and do not replace the runner's traps or disable `errexit` with conditional sourcing.
- Return nonzero when required work is incomplete, including missing authentication
  or prerequisites. Zero means complete or already satisfied.
- Use direct Omarchy commands such as `omarchy-pkg-add` and `omarchy-plugin-add`;
  do not add package caches, wrappers, or use the `omarchy` dispatcher.
- Except for bootstrap, keep scripts idempotent. Retain guards for data preservation,
  duplicate creation, authentication, toggles, and prerequisites—not speed or silence.
- Keep useful output and errors visible. Empty queues must perform no setup work.
- Check YADM ownership before writing configuration files. Do not duplicate or
  overwrite YADM-managed configuration.
- Do not add or broaden destructive operations without explicit instruction.

## Validation and delivery

Run `./scripts/check.sh` for Bash syntax, ShellCheck, shfmt, and staged/unstaged
diff checks. It requires ShellCheck and shfmt. Do not execute installation entry
points or `update.sh` for testing.
Do not add, maintain, or run a test suite unless explicitly requested.

Commit and push completed changes, including scheduled or consumed migration links
when applicable, and provide the GitHub commit link.
