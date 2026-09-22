# Omarchy Install Scripts

This repository automates my machine setup for Omarchy environments.

## 1Password service accounts

`configs/common/install-op-service.sh` installs `~/bin/op-service` on both
laptops. It requires 1Password CLI (`op`), `secret-tool` (libsecret), and an
unlocked desktop login keyring. The launcher code syncs through Git; tokens do
not. The login keyring is accessible to applications running as your user, so
use a service account limited to the vaults and permissions you need.

Save the service-account token in your personal 1Password vault. On each laptop,
copy the token field's **secret reference** (not its value), then run:

```bash
op-service setup 'op://Private/Service account — Lenovo/credential'
op-service check
```

Replace the example reference with the copied reference for that laptop.
Setup uses your personal 1Password login (enable CLI integration in the desktop
app) to copy the token directly into the local keyring without printing it.
It validates the token before replacing an existing keyring entry. Repeat setup
after rotating the token. An unavailable keyring stops the command; there is no
fallback to personal 1Password access.

Launch a coding agent, script, or application with:

```bash
op-service run -- your-agent-command
op-service run -- ./your-script.sh
op-service run -- op run --env-file=.env.op -- your-app-command
```

For the final example, `.env.op` holds references such as
`API_KEY=op://Agents/My API/credential`, not secret values. The launched
process and its children receive `OP_SERVICE_ACCOUNT_TOKEN`; existing apps and
desktop launcher shortcuts do not. Fully quit an existing app before launching
it this way. This provides 1Password authentication, not automatic integration
with every application's credential settings. Avoid commands that print their
environment or secrets when running inside an agent session.
