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
The queue command checks arguments, repository containment, and conflicting entries;
the apply command validates script paths, file types, and laptop scopes before running
any migrations.

Commit and push queued links, then pull and run `./apply-migrations.sh` on the
target laptop. Each successful script is counted and its link removed. The first
execution or removal failure stops the run with a nonzero exit status; failed and
unexecuted links remain for retry. Invalid or broken links are rejected and retained.
Success is determined by exit status, not whether stderr is empty.
