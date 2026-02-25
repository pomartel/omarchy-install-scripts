#!/bin/bash

if [[ -e "${HOME}/Pictures" && ! -L "${HOME}/Pictures" ]]; then
  rm -rf "${HOME}/Pictures"
fi

ln -sfn "${HOME}/Dropbox/Pictures" "${HOME}/Pictures"
ln -sfn "${HOME}/Dropbox/Cours" "${HOME}/Cours"

ln -sfn "${HOME}/Dropbox/CV" "${HOME}/Documents/CV"
ln -sfn "${HOME}/Dropbox/Omarchy" "${HOME}/Documents/Omarchy"
