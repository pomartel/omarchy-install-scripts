#!/bin/bash

source ./scripts/migrations.sh || exit
install_validate_hostname
install_run_fragments packages "${1:---all}"
