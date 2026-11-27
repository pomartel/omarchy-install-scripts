# journald defaults to 10% of the file system (capped at 4G), which kept about
# nine months of logs on Lenovo. 500M keeps roughly a month; journald removes
# older archives itself when it restarts with the lower limit.
journald_conf=/etc/systemd/journald.conf.d/00-max-use.conf
journald_settings=$'[Journal]\nSystemMaxUse=500M'

if [[ -f $journald_conf && $(<"$journald_conf") == "$journald_settings" ]]; then
  return 0
fi

printf '%s\n' "$journald_settings" | sudo install -D -m 0644 /dev/stdin "$journald_conf"
sudo systemctl restart systemd-journald
