#!/bin/bash

if ! omarchy toggle enabled crash-capture-off; then
  omarchy toggle crash-capture
fi
