#!/bin/bash

link_dropbox_folder() {
  local folder="$1"
  local target="${HOME}/${folder}"
  local source="${HOME}/Dropbox/${folder}"

  if [[ -L "$target" && $(readlink "$target") == "$source" ]]; then
    return
  fi

  if [[ -e "${target}" && ! -L "${target}" ]]; then
    rm -rf "${target}"
  fi

  ln -sfn "${source}" "${target}"
}

link_dropbox_folder "Documents"
link_dropbox_folder "Pictures"
link_dropbox_folder "Videos"
link_dropbox_folder "Cours"
unset -f link_dropbox_folder
