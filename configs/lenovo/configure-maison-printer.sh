#!/bin/bash
# Temporary libcupsfilters #301 workaround; see maison-pdf-normalize.md.

maison_source="$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")/maison-pdf-normalize"
maison_filter=/usr/lib/cups/filter/maison-pdf-normalize
maison_state=/var/lib/maison-pdf-fix
maison_ppd=$(sudo cat /etc/cups/ppd/Maison.ppd)
maison_routes='*cupsFilter2: "application/pdf image/urf 0 maison-pdf-normalize"
*cupsFilter2: "application/vnd.cups-pdf image/urf 0 maison-pdf-normalize"'

if grep -Fqx '*cupsFilter2: "application/pdf image/urf 0 maison-pdf-normalize"' <<<"$maison_ppd" &&
  grep -Fqx '*cupsFilter2: "application/vnd.cups-pdf image/urf 0 maison-pdf-normalize"' <<<"$maison_ppd" &&
  sudo cmp -s "$maison_source" "$maison_filter"; then
  return
fi

if sudo test -e "$maison_filter" || sudo test -e "$maison_state"; then
  echo 'Existing Maison workaround differs; review it before reinstalling.' >&2
  return 1
fi
if [[ -n $(lpstat -W not-completed -o Maison) ]]; then
  echo 'Maison has pending jobs; wait before changing its filter.' >&2
  return 1
fi
for maison_dependency in /usr/bin/qpdf /usr/bin/python3 /usr/lib/cups/filter/pdftopdf /usr/lib/cups/filter/gstoraster; do
  if [[ ! -x $maison_dependency ]]; then
    echo "Missing dependency: $maison_dependency" >&2
    return 1
  fi
done
if ! grep -Fqx '*cupsFilter2: "image/urf image/urf 0 -"' <<<"$maison_ppd" ||
  grep -Eq '^\*cupsFilter2: "application/(pdf|vnd.cups-pdf) ' <<<"$maison_ppd"; then
  echo 'Unexpected Maison driver or existing PDF route; review required.' >&2
  return 1
fi

sudo install -d -m 755 "$maison_state"
printf '%s\n' "$maison_ppd" | sudo tee "$maison_state/original.ppd" >/dev/null
printf '%s\n%s\n' "$maison_ppd" "$maison_routes" | sudo tee "$maison_state/patched.ppd" >/dev/null
sudo install -m 755 "$maison_source" "$maison_filter"
if ! sudo lpadmin -p Maison -P "$maison_state/patched.ppd"; then
  sudo lpadmin -p Maison -P "$maison_state/original.ppd"
  return 1
fi
