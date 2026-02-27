# Omarchy Install Scripts

This repository automates machine setup for Omarchy environments.

## How this repo works

- `NEW-INSTALL.sh` is for a fresh machine.
- `INSTALL.sh` is idempotent and can be re-run safely to apply packages and configuration.
- `set-target.sh` sets `INSTALL_TARGET` from hostname so target-specific scripts can run.

## Clone this repo

```bash
git clone git@github.com:pomartel/omarchy-install-scripts.git ~/Install
```

## Install flows

### Fresh install (new machine)

Run:

```bash
./NEW-INSTALL.sh
```

This flow:

1. Loads machine target from `set-target.sh`
2. Installs SSH key from 1Password with `configs/install-ssh-key-from-1password.sh`
3. Installs and initializes yadm with `configs/install-yadm.sh`
4. Runs `INSTALL.sh`

### Idempotent install/update

Run:

```bash
./INSTALL.sh
```

This flow:

1. Loads machine target from `set-target.sh`
2. Installs packages via `packages/add-packages.sh`
3. Applies all configuration scripts under `configs/`

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

- `install-ssh-key-from-1password.sh`: Reads the SSH private/public key from 1Password (based on `INSTALL_TARGET`) and writes key files to `~/.ssh`.
- `install-yadm.sh`: Installs yadm, clones `git@github.com:pomartel/config-files.git`, resets work tree to repo state, applies alternates, and decrypts secrets.
- `set-locale.sh`: Sets system locale to `en_CA.UTF-8` for `home`, or `fr_CA.UTF-8` for `school`.
- `copy-sudoers-rules.sh`: Writes `/etc/sudoers.d/custom-sudoers-rules` with custom sudo timeout and tty ticket behavior.
- `set-power-profile-rule.sh`: Writes `/etc/udev/rules.d/99-power-profile.rules` to switch power profile on AC unplug/plug.
- `clone-git-projects.sh`: Clones predefined git repositories into `~/Work` if missing.
- `remove-default-apps.sh`: Removes selected default Omarchy webapps and drops selected packages.
- `set-default-font.sh`: Sets Omarchy font to `JetBrainsMonoNL Nerd Font` if not already active.
- `configure-hibernation.sh`: Writes systemd sleep and logind drop-in files to enable suspend-then-hibernate behavior.
