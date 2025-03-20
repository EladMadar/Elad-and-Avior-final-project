#!/bin/bash

# Exit on error
set -e

# Wait for postgres
until PGPASSWORD=$POSTGRES_PASSWORD psql -h "db" -U "statuspage" -d "statuspage" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing command"

# Apply database migrations
echo "Applying database migrations..."
python statuspage/manage.py migrate

# Create superuser if not exists
if [ "$DJANGO_SUPERUSER_USERNAME" ] && [ "$DJANGO_SUPERUSER_EMAIL" ] && [ "$DJANGO_SUPERUSER_PASSWORD" ]; then
    python statuspage/manage.py createsuperuser \
        --noinput \
        --username $DJANGO_SUPERUSER_USERNAME \
        --email $DJANGO_SUPERUSER_EMAIL
fi

# Start command
exec "$@"
