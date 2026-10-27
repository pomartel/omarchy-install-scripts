#!/bin/bash

omarchy-pkg-add rust
cargo install wl-relabel --version '=0.1.1' --locked --root "$HOME/.local"
