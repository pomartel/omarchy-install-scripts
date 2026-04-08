if omarchy-cmd-missing confetti; then

  install_dir="/usr/local/bin"
  bin_name="confetti"
  repo="Skxxtz/sherlock-confetti"

  tmp_dir="$(mktemp -d)"

  echo "Installing ${bin_name} to ${install_dir}/${bin_name}"

  latest_tag="$(gh release view -R "${repo}" --json tagName -q .tagName)"
  if [[ -z "${latest_tag}" ]]; then
    echo "Could not determine latest release tag." >&2
  fi

  asset_name="confetti-v${latest_tag}-bin-linux-x86_64.tar.gz"
  gh release download -R "${repo}" -p "${asset_name}" -D "${tmp_dir}" --clobber

  archive_path="${tmp_dir}/${asset_name}"
  if [[ ! -f "${archive_path}" ]]; then
    echo "Could not find a linux x86_64 asset in latest release." >&2
  fi

  tar -xzf "${archive_path}" -C "${tmp_dir}"

  if [[ ! -f "${tmp_dir}/${bin_name}" ]]; then
    echo "Binary not found after extraction: ${bin_name}" >&2
  fi

  sudo install -m 0755 "${tmp_dir}/${bin_name}" "${install_dir}/${bin_name}"

fi
