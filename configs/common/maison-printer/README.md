# Maison printer

`packages/common/printing.sh` installs CUPS, cups-filters and Avahi and enables
their services. `configure-maison-printer.sh` creates the `Maison` queue when
missing, including during a fresh installation away from home.

- Printer: HP LaserJet Professional P1102w.
- Connection: the printer's IPP DNS-SD service name, without a fixed IP address.
- Defaults for a new queue: Letter, monochrome, one-sided.
- Errors: retry the job rather than stop the printer.
- Resume: user `po` can run `sudo /usr/bin/cupsenable Maison` without a password.
- Default destination: Maison only if no system default already exists.

`Maison.ppd` is the working driverless profile exported from Lenovo on
2026-10-16. Its old supplies-page IP address was removed and its manufacturer
and inch labels normalized for PPD validation. It allows offline creation
without querying the printer; printing still requires access to the home network.
Existing queues retain their driver and print preferences.
