#!/bin/sh

set -e

echo "-- Waiting for database..."
while ! pg_isready -U "${DB_USER:-akkoma}" -d "postgres://${DB_HOST:-db}:${DB_PORT:-5432}/${DB_NAME:-akkoma}" -t 1; do
    sleep 1s
done

echo "-- Running migrations..."
"$HOME"/bin/pleroma_ctl migrate

echo "-- Starting!"
exec "$HOME"/bin/pleroma start
