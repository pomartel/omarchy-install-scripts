#!/bin/bash

link_dropbox_folder() {
  local folder="$1"
  local target="${HOME}/${folder}"
  local source="${HOME}/Dropbox/${folder}"

  if [[ ! -d "$source" ]]; then
    printf 'Dropbox folder is not ready: %s. Wait for synchronization and retry.\n' "$source" >&2
    return 1
  fi

  if [[ -L "$target" ]]; then
    if [[ $(readlink -- "$target") == "$source" ]]; then
      return 0
    fi
    printf 'Refusing to replace an existing symlink: %s\n' "$target" >&2
    return 1
  fi

  if [[ -d "$target" ]]; then
    # rmdir only removes empty directories; existing files must be preserved.
    rmdir -- "$target" || return
  elif [[ -e "$target" ]]; then
    printf 'Refusing to replace an existing file: %s\n' "$target" >&2
    return 1
  fi

  ln -sT -- "$source" "$target"
}

link_dropbox_folder "Documents"
link_dropbox_folder "Pictures"
link_dropbox_folder "Videos"
link_dropbox_folder "Cours"
unset -f link_dropbox_folder
