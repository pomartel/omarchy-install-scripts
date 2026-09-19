#!/bin/bash

# Glance face unlock. Prefer the AUR package; the fallback builds the
# project's official PKGBUILD because the package may not be published yet.
install_glanced_from_source() {
  local glance_version="v0.2.0"
  local build_dir

  build_dir=$(mktemp -d /tmp/glanced-build.XXXXXX)
  git clone --depth 1 --branch "$glance_version" \
    https://github.com/ayandexyz/glance-linux.git "$build_dir/glance-linux"
  (
    cd "$build_dir/glance-linux/packaging/aur" || exit 1
    makepkg -s --noconfirm --needed
  )
  sudo pacman -U --noconfirm \
    "$build_dir"/glance-linux/packaging/aur/glanced-[0-9]*.pkg.tar.zst
  rm -rf "$build_dir"
}

if ! pacman -Q glanced &>/dev/null; then
  if yay -Si glanced &>/dev/null; then
    omarchy-pkg-aur-add glanced
  else
    install_glanced_from_source
  fi
fi

unset -f install_glanced_from_source
