# Install the latest OmaMarp default-branch commit on both laptops.
omamarp_source="${XDG_CACHE_HOME:-$HOME/.cache}/omamarp/source"

omarchy-pkg-add base-devel git qt6-base qt6-declarative qt6-webengine qt6-svg desktop-file-utils hunspell

# Keep the build checkout separate from the development project.
if [[ ! -d "$omamarp_source/.git" ]]; then
  mkdir -p "$(dirname "$omamarp_source")"
  git clone --no-checkout git@github.com:pomartel/OmaMarp.git "$omamarp_source"
fi
git -C "$omamarp_source" fetch origin HEAD
git -C "$omamarp_source" checkout --detach FETCH_HEAD
"$omamarp_source/bin/install"
