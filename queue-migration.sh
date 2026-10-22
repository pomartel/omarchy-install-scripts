#!/bin/bash

set -euo pipefail

usage() {
  printf 'Usage: %s PATH {lenovo|asus|common}\n' "$0" >&2
  exit 1
}

[[ $# == 2 ]] || usage
case $2 in
lenovo | asus | common) target=$2 ;;
*) usage ;;
esac

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
cd -- "$repo"
script=$(realpath -e -- "$1")
relative=${script#"$repo/"}
if [[ $script != "$repo/"* ]]; then
  printf 'Expected a path inside %s.\n' "$repo" >&2
  exit 1
fi

targets=("$target")
[[ $target != common ]] || targets=(lenovo asus)

# Check both destinations before creating either link.
for laptop in "${targets[@]}"; do
  link="migrations/$laptop/$relative"
  destination=$(realpath -m --relative-to="$(dirname -- "$link")" -- "$script")
  if [[ -e $link || -L $link ]]; then
    if [[ ! -L $link ]] || [[ $(readlink -- "$link") != "$destination" ]]; then
      printf 'Migration entry already exists and conflicts: %s\n' "$link" >&2
      exit 1
    fi
  fi
done

for laptop in "${targets[@]}"; do
  link="migrations/$laptop/$relative"
  [[ ! -L $link ]] || continue
  mkdir -p -- "$(dirname -- "$link")"
  ln -s -- "$destination" "$link"
  printf 'Queued %s for %s.\n' "$relative" "$laptop"
done
