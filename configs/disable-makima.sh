#!/bin/bash
#
if systemctl is-active --quiet makima.service; then
  sudo systemctl mask --now makima.service
fi
