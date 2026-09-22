# Omarchy Install Scripts

This repository automates my machine setup for Omarchy environments.

## 1Password service accounts

UWSM automatically sources the local `~/.config/uwsm/env.d/secrets` file at
login, without a custom loader. This file must have permissions `600`
and contain an exported `OP_SERVICE_ACCOUNT_TOKEN`. Keep the real token out of
Git, Dropbox, shell history, and command output. It is stored as plaintext on
disk and made available to applications in the desktop session.

The token authenticates 1Password CLI against the service account's permitted
vaults, including `Agents`, without personal-account approval prompts. Save a
backup of the token in your Private 1Password vault. Provision the secrets file
separately on Lenovo and Asus; the installer does not sync credentials.

Log out and back in after changing secrets so applications inherit the updated
environment. Existing processes keep their previous environment. No custom
wrapper is required. For an application that needs individual credentials:

```bash
op run --env-file=.env.op -- your-app-command
```

`.env.op` holds references such as `API_KEY=op://Agents/My API/credential`,
not secret values. Avoid printing the environment or secret values in agent
sessions.
