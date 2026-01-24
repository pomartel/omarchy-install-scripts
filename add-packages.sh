#!/bin/bash

shopt -s nullglob

for pkg_script in ./packages/common/*.sh; do
    bash "$pkg_script"
done

for pkg_script in ./packages/$INSTALL_TARGET/*.sh; do
    bash "$pkg_script"
done