# Omarchy Install Scripts

This repository automates my machine setup for Omarchy environments.

## 1Password service accounts

At desktop login, an Omarchy post-boot hook starts
`agents-session-token.service`. It waits for the 1Password desktop app to start,
then fetches `op://Private/Service Account Auth Token for Agents/credential`
through desktop CLI integration. Approve that read when prompted. If the app is
locked, you may also need to unlock it.

The service validates access to `Agents`, then uses `uwsm finalize` to publish
`OP_SERVICE_ACCOUNT_TOKEN` to the desktop session and register it for cleanup
at logout. No plaintext token file or keyring copy is created. The token is
available in the session environment to newly launched applications; apps
already running need restarting. Locking 1Password does not revoke the loaded
token. Normal `op` commands then use the service account without further
personal-account prompts.

The common installer installs the helper in `~/bin`, the systemd user service,
and the post-boot hook on both laptops. It does not start the service during
installation. Both laptops must have the 1Password desktop app's CLI integration
and autostart enabled, with access to the referenced item in Private.

If authorization is cancelled, times out, or the token is rotated, retry with
`systemctl --user restart agents-session-token.service`. Start applications
that need credentials after that command succeeds. Stopping the service clears
the token from the systemd manager; running applications retain their copy until
closed. Old plaintext `OP_SERVICE_ACCOUNT_TOKEN` assignments in UWSM files must
be removed separately; the installer does not edit existing secret files.

For an application that needs individual credentials:

```bash
op run --env-file=.env.op -- your-app-command
```

`.env.op` holds references such as `API_KEY=op://Agents/My API/credential`,
not secret values. Avoid printing the environment or secret values in agent
sessions.
