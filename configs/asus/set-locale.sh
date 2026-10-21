#!/bin/bash

sudo localectl set-locale "LANG=fr_CA.UTF-8"

if [[ $(omarchy-language) != fr ]]; then
  omarchy-language fr
fi
