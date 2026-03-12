# Omarchy Install Scripts

This repository automates machine setup for Omarchy environments.

## How this repo works

- `NEW-INSTALL.sh` is for a fresh machine.
- `INSTALL.sh` is idempotent and can be re-run safely to apply packages and configuration.
- `set-target.sh` sets `INSTALL_TARGET` from hostname so target-specific scripts can run.
- `packages/add-packages.sh` sources package scripts for `common` and the current target.
- `configs/apply-configs.sh` sources config scripts for `common` and the current target.

## Clone this repo

```bash
git clone https://github.com/omarchy-install-scripts.git ~/Install
```

## Install flows

### Fresh install (new machine)

Before running the fresh install, make sure your SSH keys are already set up in 1Password on the machine.

Run:

```bash
./NEW-INSTALL.sh
```

This flow:

1. Loads machine target from `set-target.sh`
2. Installs and initializes yadm with `configs/new-install/install-yadm.sh`
3. Runs `INSTALL.sh`

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

Package scripts are sourced in this order:

1. `packages/common/*.sh`
2. `packages/$INSTALL_TARGET/*.sh`

Notes:

- `packages/add-packages.sh` uses `source`, so package scripts run in the current shell.
- `packages/common/_node.sh` is prefixed with `_` so it sorts first and installs Node before other npm-based scripts.
- `packages/old/` contains inactive scripts that are not loaded automatically.

Current package scripts:

- `common/_node.sh`: Installs the Omarchy Node development environment when `node` is missing.
- `common/brave.sh`: Installs Brave.
- `common/chokidar.sh`: Installs `chokidar-cli` globally with npm.
- `common/codex.sh`: Installs `openai-codex`.
- `common/confetti.sh`: Downloads and installs the latest `confetti` binary from GitHub Releases.
- `common/dropbox.sh`: Installs Dropbox through Omarchy helpers.
- `common/espanso.sh`: Installs Espanso and starts its user service.
- `common/fonts.sh`: Installs the Ubuntu font family.
- `common/ghostty.sh`: Installs Ghostty through Omarchy helpers.
- `common/gitlab.sh`: Installs `glab`.
- `common/hyprland-monitor-attached.sh`: Installs `hyprland-monitor-attached`.
- `common/intel-media-driver.sh`: Installs the Intel VAAPI media driver.
- `common/keyd.sh`: Installs and enables `keyd`, then symlinks the config from `~/.config/keyd/default.conf`.
- `common/live-server.sh`: Installs `live-server` globally with npm.
- `common/marp.sh`: Installs the Marp CLI globally with npm.
- `common/onedrive.sh`: Installs `onedrive-abraunegg`.
- `common/pandoc.sh`: Installs Pandoc.
- `common/rsync.sh`: Installs `rsync`.
- `common/shfmt.sh`: Installs `shfmt`.
- `common/teams.sh`: Installs the Microsoft Teams web app if its desktop entry is missing.
- `common/todoist.sh`: Installs the Todoist CLI globally with npm.
- `common/trash.sh`: Installs `trash-cli`.
- `common/typora-themes.sh`: Clones and installs Typora default themes into `~/.config/Typora/themes`.
- `common/voxtype.sh`: Installs Voxtype and registers its user service.
- `common/zed.sh`: Installs Zed and Omazed, then runs `omazed setup` if needed.
- `home/anylist.sh`: Installs the Anylist web app.
- `home/aws-cli.sh`: Installs `aws-cli`.
- `home/calibre.sh`: Installs Calibre.
- `home/heroku.sh`: Installs the Heroku CLI globally with npm.
- `home/memcached.sh`: Installs Memcached.
- `home/mkcert.sh`: Installs `mkcert` and `nss`.
- `home/nginx.sh`: Installs and enables Nginx.
- `home/postgresql.sh`: Installs PostgreSQL, initializes the cluster if needed, enables the service, and creates the `po` superuser if missing.
- `home/redis.sh`: Installs and enables Redis.
- `home/restsic.sh`: Installs `restic`.
- `home/ruby-erb.sh`: Installs `ruby-erb`.
- `home/ruby-on-rails.sh`: Installs the Omarchy Ruby development environment when `rails` is missing.
- `home/yarn.sh`: Installs Yarn.
- `school/man-pages-fr.sh`: Installs French man pages.
- `school/networking.sh`: Installs and configures NetworkManager with `wpa_supplicant`, disables conflicting services, and removes the `nm-applet` autostart desktop entry.

Inactive package scripts:

- `old/airplay.sh`: Installs AirPlay support for Pipewire and opens firewall ports for streaming.

## Configuration scripts (`configs/`)

Configuration scripts are sourced in this order:

1. `configs/common/*.sh`
2. `configs/$INSTALL_TARGET/*.sh`

Notes:

- `configs/apply-configs.sh` also uses `source`, so config scripts run in the current shell.
- `configs/new-install/` contains scripts used only by `NEW-INSTALL.sh`.
- `configs/old/` contains inactive scripts that are not loaded automatically.

Current config scripts:

- `common/clone-git-projects.sh`: Clones predefined repositories into `~/Work`, including extra home-only repositories when `INSTALL_TARGET=home`.
- `common/configure-hibernation.sh`: Writes systemd sleep and logind drop-ins for suspend-then-hibernate behavior.
- `common/copy-sudoers-rules.sh`: Writes `/etc/sudoers.d/custom-sudoers-rules` with custom sudo timeout and tty ticket behavior.
- `common/create-dropbox-symlinks.sh`: Replaces local folders if needed and symlinks `Documents`, `Pictures`, `Videos`, and `Cours` to Dropbox.
- `common/disable-plocate.sh`: Masks `plocate-updatedb.timer` when it is active.
- `common/remove-default-apps.sh`: Removes selected default Omarchy web apps, drops `signal-desktop` and `alacritty`, and deletes `~/Work/tries`.
- `common/set-default-font.sh`: Sets the Omarchy font to `JetBrainsMonoNL Nerd Font` when needed.
- `home/configure-bluetooth-wake.sh`: Installs Bluetooth wake udev rules, enables wake on current Bluetooth controllers, and enables wake for paired HID devices when possible.
- `home/enable-config-backup.sh`: Enables the `config-backup.timer` user service when it is not already active.
- `home/set-locale.sh`: Sets system locale to `en_CA.UTF-8`.
- `school/set-locale.sh`: Sets system locale to `fr_CA.UTF-8`.

Fresh-install-only config scripts:

- `new-install/install-yadm.sh`: Installs yadm, clones `git@github.com:pomartel/config-files.git`, resets work tree to repo state, applies alternates, and decrypts secrets.

Inactive config scripts:

- `old/set-power-rules.sh`: Writes `/etc/udev/rules.d/99-power-profile.rules`, sets display brightness rules, and enables `powerprofile-low-battery.timer`.
