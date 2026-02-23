#!/bin/bash

item_title="SSH $INSTALL_TARGET"
ssh_dir="$HOME/.ssh"
key_name="id_ed25519"
private_path="$ssh_dir/$key_name"
public_path="$private_path.pub"

private_key=$(op read "op://Private/$item_title/private key?ssh-format=openssh" || true)

if [ -z "$private_key" ]; then
  echo "ERROR: Could not read private key field 'private key' from 1Password item '$item_title'." >&2
  exit 1
fi
#
mkdir -p "$ssh_dir"
chmod 700 "$ssh_dir"

printf '%s\n' "$private_key" >"$private_path"
chmod 600 "$private_path"

public_key=$(op read "op://Private/$item_title/public key?ssh-format=openssh" || true)

if [ -z "$public_key" ]; then
  public_key="$(ssh-keygen -y -f "$private_path" 2>/dev/null || true)"
fi

if [ -z "$public_key" ]; then
  echo "ERROR: Could not resolve public key from item 'public key' or derive it from private key." >&2
  exit 1
fi

printf '%s\n' "$public_key" >"$public_path"
chmod 644 "$public_path"

echo "Installed SSH key '$key_name' from 1Password item '$item_title'."
