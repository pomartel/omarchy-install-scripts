# Temporary Maison PDF workaround

**Status on 2026-11-24: still required on Lenovo.** The standard filter still
turns PDFs with combined ASCII85/Flate compression into blank pages. Keep this
workaround until the installed printing stack passes the checks below.

## Cause and upstream status

The PDFio-based `pdftopdf` cannot decode streams using
`/Filter [/ASCII85Decode /FlateDecode]`, used by ReportLab's default compression.
It reports `Unsupported compound stream filter` but exits successfully and
produces blank pages. A successful CUPS job or a nonempty output file is therefore
not evidence that printable content survived.

The fix is planned for PDFio 1.7. As of this check, the latest published release
is 1.6.6 and the development changelog still lists 1.7.0 without a release date.
Lenovo has PDFio 1.6.5, and its installed `libcupsfilters.so.2` links to that
library. An upstream issue being closed does not establish that the fix has
reached the installed package.

Sources checked on 2026-11-24:

- [libcupsfilters issue 301](https://github.com/OpenPrinting/libcupsfilters/issues/301)
- [PDFio issue 11, assigned to version 1.7](https://github.com/michaelrsweet/pdfio/issues/11)
- [PDFio releases](https://github.com/michaelrsweet/pdfio/releases)
- [PDFio development changelog](https://github.com/michaelrsweet/pdfio/blob/master/CHANGES.md)

## Local verification on 2026-11-24

Installed versions: `pdfio 1.6.5-1`, `libcupsfilters 2.2.1.r32.gd49e9284-1`,
`cups-filters 2.0.1-3`, `cups 2:2.4.20-1`, `ghostscript 10.08.0-1`, and
`qpdf 12.4.2-1`.

The check used a controlled two-page ReportLab 4.4.9 document with text and a
filled rectangle, generated both with and without ASCII85 compression. It did
not use the historical failing document. Both input compression variants were
checked before filtering.

The current Maison PPD was downloaded from the local CUPS server. A temporary
copy with only the two workaround routes removed represented the standard chain.
All conversions wrote local files; no job was submitted and no queue was changed.

| Input and conversion                     | Exit code | Result in final URF raster                       |
| :--------------------------------------- | --------: | :----------------------------------------------- |
| ASCII85/Flate through the standard chain  |         0 | Two blank pages; compound-stream error logged     |
| Flate-only control, standard chain       |         0 | Two nonblank pages                               |
| ASCII85/Flate through the installed fix  |         0 | Two nonblank pages, identical to the control      |
| ASCII85/Flate through Maison's PPD route |         0 | Two nonblank pages, identical to the control      |

The last check used `cupsfilter -e -p CURRENT_PPD -i application/pdf
-m printer/Maison INPUT.pdf`, so CUPS selected `maison-pdf-normalize` from the PPD.
URF was decoded with the installed CUPS raster API. The two corrected pages
contained 4,709,797 and 4,711,041 nonwhite pixels; both uncorrected pages contained
zero. All raster pages were 4961 by 7016 pixels with the current defaults.

The intermediate PDFs were also rendered with Poppler and visually checked:
the uncorrected pages were white; the normalized pages retained the text and
rectangle. The installed filter and its repository copy are identical.

These are software conversion checks, not a new physical print test. Earlier
checks covered page selection, copies, and layout options; those cases were not
all repeated on this date.

## Scope and installation

`configure-maison-printer.sh` installs the filter for Maison only. It leaves an
identical installation alone and refuses to replace another filter, overwrite
its backup, or change a queue with pending jobs. `packages/lenovo/qpdf.sh` supplies
qpdf; the normal CUPS filters and Python must already be installed.

The filter normalizes a temporary copy with qpdf before the standard CUPS
filters. It preserves the original PDF, avoids applying page/copy management
twice to `application/vnd.cups-pdf`, and buffers the final raster before sending
it. Conversion errors and the known compound-stream error stop output.

## Recheck after printing-stack updates

1. Record `pacman -Q pdfio libcupsfilters cups-filters cups ghostscript qpdf`
   and check the upstream release notes. A version number alone is insufficient.
2. Generate a two-page PDF with ReportLab's default ASCII85 compression using
   the reproducer in issue 301, with visible text and a filled rectangle on both
   pages. Keep a Flate-only control. Do not normalize the failing input first.
3. Run the installed `pdftopdf` directly on the original input. This bypasses the
   PPD's workaround without changing the live queue:

   ```sh
   pdf=/path/to/reportlab-compound.pdf
   work=$(mktemp -d)
   curl --fail --silent --show-error http://localhost:631/printers/Maison.ppd > "$work/Maison.ppd"
   PPD="$work/Maison.ppd" CONTENT_TYPE=application/pdf \
     /usr/lib/cups/filter/pdftopdf 1 "$USER" verification 1 "" "$pdf" \
     > "$work/standard.pdf" 2> "$work/standard.log"
   qpdf --decode-level=generalized --recompress-flate "$pdf" "$work/normalized.pdf"
   PPD="$work/Maison.ppd" CONTENT_TYPE=application/pdf \
     /usr/lib/cups/filter/pdftopdf 1 "$USER" verification 1 "" "$work/normalized.pdf" \
     > "$work/normalized-standard.pdf" 2> "$work/normalized-standard.log"
   pdftoppm -r 72 -gray -png "$work/standard.pdf" "$work/standard"
   pdftoppm -r 72 -gray -png "$work/normalized-standard.pdf" "$work/normalized"
   ```

4. Inspect both pages and logs. The original input must retain its text and
   graphics without the compound-stream error. Compare with the control; do not
   rely only on the exit code or the number of pages.
5. Repeat the final URF conversion with a temporary PPD copy containing only the
   standard routes. Check nonblank raster content, page selection, and copies.
   Keep the workaround if any of these checks fail.

## Retirement and rollback

Retire this workaround only after the unmodified standard chain passes those
checks. Before changing Maison, check `lpstat -W not-completed -o Maison` and wait
for pending jobs to finish. Compare its current PPD with the saved original:
`/var/lib/maison-pdf-fix/original.ppd`. If the only differences are the workaround
routes and comment, restore the saved PPD:

```sh
sudo lpadmin -p Maison -P /var/lib/maison-pdf-fix/original.ppd
```

If the printer configuration has changed since that backup, preserve those
changes and remove only the workaround routes from a copy of the current PPD.
Keep the inactive filter and backup until a physical print is confirmed correct.
Do not mistake a CUPS completed status for confirmation of paper output.

Once retirement is verified, remove the workaround installer and filter asset
from Install, along with any pending migration links, so bootstrap cannot restore
it. Review `packages/lenovo/qpdf.sh` separately: qpdf may still be useful for other
PDF work. Keep this note as the explanation of why the workaround was removed.
