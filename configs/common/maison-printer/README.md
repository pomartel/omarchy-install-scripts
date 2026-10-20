# Maison printer

Omarchy installs CUPS, cups-filters and Avahi and enables their services.
`configure-maison-printer.sh` creates the `Maison` queue when missing.

- Printer: HP LaserJet Professional P1102w.
- Connection: the printer's IPP DNS-SD service name, without a fixed IP address.
- Defaults for a new queue: Letter, monochrome, one-sided.
- Errors: retry the job rather than stop the printer.
- Default destination: Maison only if no system default already exists.

The queue uses `-m everywhere` to query the printer for its driverless profile.
Initial creation requires the printer to be reachable on the home network.
Existing queues are left unchanged.
