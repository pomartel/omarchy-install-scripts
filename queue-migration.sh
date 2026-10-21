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
if [[ ! -f $script || ! $relative =~ ^(packages|configs)/(common|lenovo|asus)/([^/]+\.sh)$ ]]; then
  printf 'Expected a Bash fragment under packages/{common,lenovo,asus} or configs/{common,lenovo,asus}.\n' >&2
  exit 1
fi
scope=${BASH_REMATCH[2]}
filename=${BASH_REMATCH[3]}
if [[ $filename == .* ]] || [[ $scope != common && $scope != "$target" ]]; then
  printf 'Script %s cannot be queued for %s.\n' "$relative" "$target" >&2
  exit 1
fi

targets=("$target")
[[ $target != common ]] || targets=(lenovo asus)

# Check both destinations before creating either link.
for laptop in "${targets[@]}"; do
  link="migrations/$laptop/$relative"
  destination="../../../../$relative"
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
