# YADM owns Flea's settings and bar placement; install only the bundled plugin.
install_flea_shelf() {
  local plugin_dir="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/io.github.thisisgm.flea-shelf"
  local source_file destination_file
  local changed=false

  mkdir -p "$plugin_dir"
  for source_file in /usr/share/flea/shelf/*; do
    destination_file="$plugin_dir/${source_file##*/}"
    if ! cmp -s "$source_file" "$destination_file"; then
      cp -a "$source_file" "$destination_file"
      changed=true
    fi
  done

  if "$changed"; then
    echo "Updated Flea Shelf plugin"
    omarchy restart shell
  fi
}

install_flea_shelf
unset -f install_flea_shelf
