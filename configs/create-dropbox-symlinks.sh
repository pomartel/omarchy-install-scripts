#!/bin/bash

if [[ -e "${HOME}/Pictures" && ! -L "${HOME}/Pictures" ]]; then
  rm -rf "${HOME}/Pictures"
fi

ln -sfn "${HOME}/Dropbox/Pictures" "${HOME}/Pictures"
ln -sfn "${HOME}/Dropbox/Cours" "${HOME}/Cours"
ln -sfn "${HOME}/Dropbox/CV" "${HOME}/Documents/CV"

if [[ "${INSTALL_TARGET}" == "home" ]]; then
  ln -sfn "${HOME}/Dropbox/Code-Rubik" "${HOME}/Documents/Code-Rubik"
  ln -sfn "${HOME}/Dropbox/Finances" "${HOME}/Documents/Finances"
  ln -sfn "${HOME}/Dropbox/Maison" "${HOME}/Documents/Maison"
  ln -sfn "${HOME}/Dropbox/Omarchy" "${HOME}/Documents/Omarchy"
fi
