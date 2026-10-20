# Maison and Travail printers

Omarchy installs CUPS, cups-filters and Avahi and enables their services.
`configure-maison-printer.sh` creates missing queues for reachable printers:

- `Maison`: HP LaserJet Professional P1102w at home, using its IPP DNS-SD service name.
- `Travail`: HP LaserJet M607 at the cégep, using `ipp://NPI600539.local:631/ipp/print`.

Both queues use these settings:
- Defaults for a new queue: Letter, monochrome, one-sided.
- Errors: retry the job rather than stop the printer.
- Default destination: the first created queue, only if no system default already exists.

Each queue uses `-m everywhere` to query the printer for its driverless profile.
Before creating a queue, an IPP availability check is limited to eight seconds.
Unavailable printers are skipped without interrupting installation; run the
script again on their network to create their queues.
Existing queues are left unchanged.
