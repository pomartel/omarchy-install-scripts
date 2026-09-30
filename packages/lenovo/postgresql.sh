# PostgreSQL database server
omarchy-pkg-add postgresql

# Keep a failed sudo command distinct from an uninitialized database.
postgres_data_state=$(sudo /usr/bin/bash -c '
  if [[ -d /var/lib/postgres/data/base ]]; then
    echo initialized
  else
    echo missing
  fi
')
if [[ $postgres_data_state == missing ]]; then
  echo "Initializing PostgreSQL database..."
  sudo -iu postgres initdb -D /var/lib/postgres/data
fi

if ! systemctl is-active --quiet postgresql; then
  sudo systemctl enable --now postgresql
fi

# A failed query must stop installation, not attempt to create a role.
postgres_role=$(sudo -iu postgres psql -v ON_ERROR_STOP=1 -tAc "SELECT 1 FROM pg_roles WHERE rolname='po'")
if [[ $postgres_role != 1 ]]; then
  echo "Creating PostgreSQL superuser 'po'..."
  sudo -iu postgres createuser --superuser po
fi
unset postgres_data_state postgres_role
