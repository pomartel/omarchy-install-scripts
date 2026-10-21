# Keep Marp outside mise's version-specific Node installations.
if [[ ! -f "$HOME/.local/share/marp/node_modules/@marp-team/marp-cli/marp-cli.js" ]]; then
  npm install --prefix "$HOME/.local/share/marp" --no-audit --no-fund @marp-team/marp-cli
fi
