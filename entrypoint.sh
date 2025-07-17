#!/bin/bash
set -e

# Create log directories if they don't exist
mkdir -p /var/log/nginx
mkdir -p /var/log/gunicorn
mkdir -p /var/log/supervisor

# Check if we're in development mode
if [ "$DJANGO_ENV" = "development" ]; then
    echo "Running in development mode (HTTP only)"
    # Disable production nginx and enable development nginx
    supervisorctl stop nginx
    supervisorctl start nginx-dev
else
    echo "Running in production mode (HTTPS)"
    # Make sure production nginx is enabled and development is disabled
    supervisorctl stop nginx-dev
    supervisorctl start nginx
fi

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Create superuser if DJANGO_SUPERUSER_* environment variables are set
if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ] && [ -n "$DJANGO_SUPERUSER_EMAIL" ]; then
    echo "Creating superuser..."
    python manage.py createsuperuser --noinput
fi

# Execute the command passed to docker run
exec "$@"