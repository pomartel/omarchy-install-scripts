# PostgreSQL database server
omarchy-pkg-add postgresql

# check if the database is already initialized
if sudo [ ! -d /var/lib/postgres/data/base ]; then
  echo "Initializing PostgreSQL database..."
  sudo -iu postgres initdb -D /var/lib/postgres/data
fi

if ! systemctl is-active --quiet postgresql; then
  sudo systemctl enable --now postgresql
fi

# check if the postgres user already exists
if ! sudo -iu postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='po'" | grep -q 1; then
  echo "Creating PostgreSQL superuser 'po'..."
  sudo -iu postgres createuser --superuser po
fi
