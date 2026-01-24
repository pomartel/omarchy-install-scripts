#!/bin/bash

current_locale=$(locale | grep LANG=)

if [[ $INSTALL_TARGET == "school" ]]; then
    target_locale="LANG=fr_CA.UTF-8"
else
    target_locale="LANG=en_CA.UTF-8"
fi

if [[ "$current_locale" != "$target_locale" ]]; then
    echo "Setting system locale to $target_locale..."
    sudo localectl set-locale $target_locale
fi
