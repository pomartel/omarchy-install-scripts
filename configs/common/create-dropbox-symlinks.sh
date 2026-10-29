#!/bin/bash

for folder in Documents Pictures Videos Cours; do
  target="$HOME/$folder"
  source="$HOME/Dropbox/$folder"
  # Documents exposes the Dropbox root; the other folders keep their subdirectory.
  if [[ $folder == Documents ]]; then
    source="$HOME/Dropbox"
  fi

  if [[ ! -d "$source" ]]; then
    printf 'Dropbox folder is not ready: %s. Wait for synchronization and retry.\n' "$source" >&2
    return 1
  fi

  if [[ -L "$target" && $(readlink -- "$target") == "$source" ]]; then
    continue
  fi

  if [[ $folder == Documents && -L "$target" ]]; then
    case $(readlink -- "$target") in
    "$HOME/Dropbox/Documents" | Dropbox/Documents)
      # Replace only the known old link, including when its destination is gone.
      # --no-dereference replaces the link itself without touching Dropbox data.
      ln -sfnT -- "$source" "$target" || return
      continue
      ;;
    esac
  fi

  if [[ -d "$target" && ! -L "$target" ]]; then
    # rmdir only removes empty directories; existing files must be preserved.
    rmdir -- "$target" || return
  fi

  # All other existing files and conflicting symlinks remain untouched.
  ln -sT -- "$source" "$target" || return
done
