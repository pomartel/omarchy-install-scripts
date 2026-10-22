#!/bin/bash

set -euo pipefail
shopt -s nullglob

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
scripts=(*.sh scripts/*.sh packages/*/*.sh configs/*/*.sh)

for script in "${scripts[@]}"; do
  bash -n "$script"
done
shellcheck -s bash "${scripts[@]}"
shfmt -d "${scripts[@]}"
git diff --check
git diff --cached --check

printf 'Static checks passed for %s shell scripts.\n' "${#scripts[@]}"
