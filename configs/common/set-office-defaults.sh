# Remove obsolete handlers while preserving other applications in each list.
for mimeapps_file in \
  "${XDG_CONFIG_HOME:-$HOME/.config}"/*mimeapps.list \
  "${XDG_DATA_HOME:-$HOME/.local/share}"/applications/*mimeapps.list; do
  [[ -f $mimeapps_file ]] || continue
  sed -i -E '
    :handlers
    s/(^|[=;])[^=;]*(onlyoffice|libreoffice)[^;]*\.desktop(;|$)/\1/I
    t handlers
    /^[^#[]+=[;[:space:]]*$/d
    /^#[[:space:]]*(OnlyOffice|LibreOffice)[[:space:]]*$/Id
  ' "$mimeapps_file"
done

# Use WordCraft for word-processing documents.
xdg-mime default ai.storyteller.wordcraft.desktop \
  application/msword \
  application/msword-template \
  application/vnd.openxmlformats-officedocument.wordprocessingml.document \
  application/vnd.openxmlformats-officedocument.wordprocessingml.template \
  application/vnd.ms-word.document.macroEnabled.12 \
  application/vnd.ms-word.template.macroEnabled.12 \
  application/vnd.oasis.opendocument.text \
  application/rtf \
  text/rtf

# Use GridCraft for spreadsheets and delimited tables.
xdg-mime default ai.storyteller.gridcraft.desktop \
  application/vnd.ms-excel \
  application/vnd.openxmlformats-officedocument.spreadsheetml.sheet \
  application/vnd.ms-excel.sheet.macroEnabled.12 \
  application/vnd.ms-excel.sheet.binary.macroEnabled.12 \
  application/vnd.oasis.opendocument.spreadsheet \
  text/csv \
  text/tab-separated-values

# Use DeckCraft for presentations, templates, and slide shows.
xdg-mime default ai.storyteller.deckcraft.desktop \
  application/x-deckcraft \
  application/vnd.openxmlformats-officedocument.presentationml.presentation \
  application/vnd.openxmlformats-officedocument.presentationml.template \
  application/vnd.openxmlformats-officedocument.presentationml.slideshow
