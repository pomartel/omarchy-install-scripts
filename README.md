# Omarchy Install Scripts

This repository automates machine setup for Omarchy environments.

## How this repo works

- `NEW-INSTALL.sh` is for a fresh machine.
- `INSTALL.sh` is idempotent and can be re-run safely to apply packages and configuration.
- `set-target.sh` sets `INSTALL_TARGET` from hostname so target-specific scripts can run.

## Clone this repo

```bash
git clone https://github.com/omarchy-install-scripts.git ~/Install
```

## Install flows

### Fresh install (new machine)

Run:

```bash
./NEW-INSTALL.sh
```

This flow:

1. Loads machine target from `set-target.sh`
2. Installs SSH key from 1Password with `configs/new-install/install-ssh-key-from-1password.sh`
3. Installs and initializes yadm with `configs/new-install/install-yadm.sh`
4. Runs `INSTALL.sh`

### Idempotent install/update

Run:

```bash
./INSTALL.sh
```

This flow:

1. Loads machine target from `set-target.sh`
2. Installs packages via `packages/add-packages.sh`
3. Applies configuration via `configs/apply-configs.sh`

## Target selection

`set-target.sh` maps hostname to target:

- `home-omarchy` -> `home`
- `school-omarchy` -> `school`

If hostname is unknown, the script exits with an error.

## Packages

Packages are loaded in this order:

1. `packages/common/*.sh`
2. `packages/$INSTALL_TARGET/*.sh`

## Configuration scripts (`configs/`)

Configuration scripts are loaded in this order:

1. `configs/common/*.sh`
2. `configs/$INSTALL_TARGET/*.sh`

- `common/copy-sudoers-rules.sh`: Writes `/etc/sudoers.d/custom-sudoers-rules` with custom sudo timeout and tty ticket behavior.
- `common/clone-git-projects.sh`: Clones shared git repositories into `~/Work` if missing.
- `home/clone-git-projects.sh`: Clones home-only git repositories into `~/Work` if missing.
- `common/create-dropbox-symlinks.sh`: Creates symlinks from `~/Dropbox` into selected home directories.
- `common/disable-plocate.sh`: Masks the `plocate-updatedb.timer` systemd timer when it is active.
- `common/remove-default-apps.sh`: Removes selected default Omarchy webapps and drops selected packages.
- `common/set-default-font.sh`: Sets Omarchy font to `JetBrainsMonoNL Nerd Font` if not already active.
- `common/configure-hibernation.sh`: Writes systemd sleep and logind drop-in files to enable suspend-then-hibernate behavior.
- `home/configure-bluetooth-wake.sh`: Enables Bluetooth wake, marks paired HID devices as wake-capable, and installs a udev rule to keep controller wake enabled after reboot.
- `home/enable-config-backup.sh`: Enables the `config-backup.timer` user service when it is not already active.
- `home/set-locale.sh`: Sets system locale to `en_CA.UTF-8`.
- `school/set-locale.sh`: Sets system locale to `fr_CA.UTF-8`.

Inactive scripts kept for later use:

- `old/set-power-rules.sh`: Writes `/etc/udev/rules.d/99-power-profile.rules` to switch power profile on AC unplug/plug.

Fresh-install-only scripts:

- `new-install/install-ssh-key-from-1password.sh`: Reads the SSH private/public key from 1Password (based on `INSTALL_TARGET`) and writes key files to `~/.ssh`.
- `new-install/install-yadm.sh`: Installs yadm, clones `git@github.com:pomartel/config-files.git`, resets work tree to repo state, applies alternates, and decrypts secrets.
