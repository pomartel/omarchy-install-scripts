# Remove LibreOffice, including installed language packs and extensions.
libreoffice_packages=()
installed_packages=$(pacman -Qq)
while IFS= read -r package_name; do
  case $package_name in
  libreoffice | libreoffice-*) libreoffice_packages+=("$package_name") ;;
  esac
done <<<"$installed_packages"

if ((${#libreoffice_packages[@]} > 0)); then
  omarchy-pkg-drop "${libreoffice_packages[@]}"
fi
