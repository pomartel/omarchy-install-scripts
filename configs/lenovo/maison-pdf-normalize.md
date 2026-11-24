# Maison PDF workaround

`configure-maison-printer.sh` installs the existing PDF normalization filter for
Maison only. It leaves an identical installation alone and refuses to replace
another filter, overwrite its backup, or change a queue with pending jobs.
`packages/lenovo/qpdf.sh` supplies qpdf; the normal CUPS filters and Python must
already be installed.

The original PPD is kept at `/var/lib/maison-pdf-fix/original.ppd`. To remove the
workaround while retaining its files and backup:

```sh
sudo lpadmin -p Maison -P /var/lib/maison-pdf-fix/original.ppd
```

The filter is unchanged from the version installed on Lenovo. Earlier checks
covered PDF normalization, page selection, copies, and raster output. Moving it
into Install does not constitute a new paper print test.
