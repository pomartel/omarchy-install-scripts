# Lenovo fingerprint recovery

Pinned from [Omarchy PR #7158](https://github.com/omacom/omarchy/pull/7158),
commit `e77ed414f28382b8efd2e2633795c73ec36c089e`.
The PR remains unmerged. This is a local workaround, not an Omarchy release.

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
patch after an incompatible Omarchy update; do not force it or overwrite the
clone. A clone does not automatically inherit later stock lock-screen updates.

## Verify on the laptop

Check normal fingerprint and password unlock, short lid closes, a longer sleep,
and an overnight unattended lock. Inspect `journalctl -u fprintd` and
`omarchy-shell lock status`; the latter should include `fingerprintUnavailable`.
Confirm the daemon changes PID after resume and that failed claims no longer
produce a continuous 250 ms retry loop. Reader-specific recovery still requires
these physical tests; patch checks alone cannot establish it.

## Roll back

While unlocked, run `omarchy plugin enable omarchy.lock`, then
`omarchy restart shell`. Review that Lenovo-only configuration change with YADM.
Remove only the two root-owned files listed above if they still match the copies
here, then run `sudo systemctl daemon-reload`. Keep the clone as a backup if desired.
Remove or disable the installer before the next `INSTALL.sh` run to avoid
reapplying the workaround.
