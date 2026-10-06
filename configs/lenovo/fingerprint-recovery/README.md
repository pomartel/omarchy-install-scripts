# Lenovo fingerprint recovery

Pinned from [Omarchy PR #7158](https://github.com/omacom/omarchy/pull/7158),
commit `e77ed414f28382b8efd2e2633795c73ec36c089e`.
The PR was merged into `quattro` on October 4, 2026, as
[`879d6583`](https://github.com/omacom/omarchy/commit/879d6583dacea9a6fe421319fe463d6cae73831b).
This installer still carries an older, pinned version of the fix. The merged
version also handles readers that prompt and then immediately fail, and improves
enrollment detection and installation/removal of the recovery files.

As checked on October 6, 2026, Lenovo's installed `omarchy 4.0.4-1` does not yet
contain the upstream lock changes or recovery-file sources, and `po.lock` is
still selected. Keep this workaround until the installed Omarchy includes the
merged fix; the merge alone does not update the laptop.

From `~/Install`, while the desktop is unlocked:

```bash
bash configs/lenovo/fingerprint-recovery.sh --check
bash configs/lenovo/fingerprint-recovery.sh
```

The script also runs through the normal Lenovo configuration runner. Both the
actual hostname and `INSTALL_TARGET` must identify Lenovo. On Asus it does nothing.
`--check` stages the patch in a temporary directory and checks prerequisites;
it does not install files, request sudo, or restart the shell.
Installation uses sudo in an interactive terminal and a graphical polkit
authentication prompt when launched without one. A repeat run with both system
files already installed does not request administrator authentication.

Pull the matching `config-files` change and run `yadm alt` first. YADM now owns
separate `shell.json##hostname.lenovo` and `shell.json##hostname.asus` files.
The installer does not generate either configuration. Omarchy's normal
clone/enable commands select `po.lock` in the Lenovo alternate only. Review
and commit that selection with YADM after applying the script.

## What gets installed

- A clone of the **currently installed** lock plugin in
  `~/.config/omarchy/plugins/po.lock`. `lock.patch` carries only the PR's
  fingerprint changes, rebased onto Lenovo's current lock files. Face unlock,
  password authentication, and layout customizations are retained.
- The upstream `FingerprintModel.js` for claim retry pacing, recovery detection,
  and the unavailable-reader indicator.
- `/usr/lib/systemd/system-sleep/fprintd-resume`, which queues a nonblocking
  `try-restart` of an already-running fprintd after resume.
- `/etc/systemd/system/fprintd.service.d/10-stop-timeout.conf`, bounding daemon
  stopping to three seconds. No reboot or re-enrollment is performed.

The installer restarts the shell with `omarchy restart shell` when the clone
or its selection changes. It does not restart fprintd during installation;
the recovery hook acts on the next resume.

## Updates and conflicts

No code is downloaded at install time. The patch, model, hook, and drop-in are
reviewable in this repository. The model, hook, and drop-in are copied verbatim
from the pinned commit; patch context was adapted to preserve Lenovo's existing
customizations without importing unrelated upstream changes.

A repeat run is silent when nothing changes. A changed stock lock plugin,
hand-edited clone, conflicting resume workaround, or incompatible patch causes
the installer to stop before replacing existing files. Rebase and review this
patch after an incompatible Omarchy update only if the upstream fix is still
absent; do not force it or overwrite the clone. Once the merged fix is installed,
retire this workaround instead of rebasing it. A clone does not automatically
inherit later stock lock-screen updates.

## Retire after the upstream update

Confirm that the installed stock lock includes `FingerprintModel.js` and the
merged fingerprint recovery logic, and that Omarchy's fingerprint migration has
installed the resume hook and three-second stop timeout listed above. Check the
installed files rather than relying on the package version alone.

Before the next `INSTALL.sh` run, remove or disable
`configs/lenovo/fingerprint-recovery.sh` so it cannot reapply the old patch.
While unlocked, run `omarchy plugin enable omarchy.lock`, then
`omarchy restart shell`. Review and commit the Lenovo-only selection change with
YADM. Keep `po.lock` as a backup until the physical checks below pass.

Keep the resume hook and stop-timeout drop-in: the merged Omarchy fix uses these
same paths and manages their lifecycle. Do not delete them when retiring the
local plugin. Verify fingerprint and password unlock after short and long
suspends before removing the backup.

## Verify on the laptop

Check normal fingerprint and password unlock, short lid closes, a longer sleep,
and an overnight unattended lock. Inspect `journalctl -u fprintd` and
`omarchy-shell lock status`; the latter should include `fingerprintUnavailable`.
Confirm the daemon changes PID after resume and that failed claims no longer
produce a continuous 250 ms retry loop. Reader-specific recovery still requires
these physical tests; patch checks alone cannot establish it.

## Roll back

These instructions undo the temporary fix **before** the upstream recovery is
installed. After the upstream update, use the retirement procedure above and
retain Omarchy's recovery files.

While unlocked, run `omarchy plugin enable omarchy.lock`, then
`omarchy restart shell`. Review that Lenovo-only configuration change with YADM.
Remove only the two root-owned files listed above if they still match the copies
here, then run `sudo systemctl daemon-reload`. Keep the clone as a backup if desired.
Remove or disable the installer before the next `INSTALL.sh` run to avoid
reapplying the workaround.
