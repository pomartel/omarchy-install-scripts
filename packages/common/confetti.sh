if omarchy-cmd-missing confetti; then

  INSTALL_DIR="/usr/local/bin"
  BIN_NAME="confetti"
  REPO="Skxxtz/sherlock-confetti"

  tmp_dir="$(mktemp -d)"

  echo "Installing ${BIN_NAME} to ${INSTALL_DIR}/${BIN_NAME}"

  latest_tag="$(gh release view -R "${REPO}" --json tagName -q .tagName)"
  if [[ -z "${latest_tag}" ]]; then
    echo "Could not determine latest release tag." >&2
  fi

  asset_name="confetti-v${latest_tag}-bin-linux-x86_64.tar.gz"
  gh release download -R "${REPO}" -p "${asset_name}" -D "${tmp_dir}" --clobber

  archive_path="${tmp_dir}/${asset_name}"
  if [[ ! -f "${archive_path}" ]]; then
    echo "Could not find a linux x86_64 asset in latest release." >&2
  fi

  tar -xzf "${archive_path}" -C "${tmp_dir}"

  if [[ ! -f "${tmp_dir}/${BIN_NAME}" ]]; then
    echo "Binary not found after extraction: ${BIN_NAME}" >&2
  fi

  sudo install -m 0755 "${tmp_dir}/${BIN_NAME}" "${INSTALL_DIR}/${BIN_NAME}"

fi
