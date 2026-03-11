#!/bin/bash

shopt -s nullglob

for config_script in ./configs/common/*.sh; do
  source "$config_script"
done

for config_script in ./configs/"$INSTALL_TARGET"/*.sh; do
  source "$config_script"
done
