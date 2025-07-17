# Blognificent Docker Guide

This document explains how to use the Docker setup for Blognificent, a modern blog application built with Django, Tailwind CSS, and DaisyUI.

## Overview

The Blognificent Docker image combines both the Django application and Nginx web server into a single container, simplifying deployment and reducing resource usage. This all-in-one container:

- Runs Django with Gunicorn
- Serves static and media files with Nginx
- Supports both HTTP (development) and HTTPS (production) modes
- Includes comprehensive Docker labels with project metadata
- Can be easily deployed to any Docker-compatible environment

## Quick Start

### Pull the Image from Docker Hub

```bash
docker pull senzoearl/blognificent:2.0
```

### Run in Production Mode (HTTPS)

```bash
docker run -p 80:80 -p 443:443 \
  -e DJANGO_ENV=production \
  -v /path/to/.env:/app/.env \
  senzoearl/blognificent:2.0
```

### Run in Development Mode (HTTP only)

```bash
docker run -p 80:80 \
  -e DJANGO_ENV=development \
  -v /path/to/.env:/app/.env \
  senzoearl/blognificent:2.0
```

## Environment Variables

The container uses the following environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `DJANGO_ENV` | Set to `development` for HTTP-only mode, or `production` for HTTPS | `production` |
| `DJANGO_SUPERUSER_USERNAME` | Username for automatically created superuser | - |
| `DJANGO_SUPERUSER_PASSWORD` | Password for automatically created superuser | - |
| `DJANGO_SUPERUSER_EMAIL` | Email for automatically created superuser | - |

Additionally, all environment variables from your `.env` file will be available to the Django application.

## Volumes

You can mount the following volumes:

| Host Path | Container Path | Purpose |
|-----------|---------------|---------|
| `/path/to/.env` | `/app/.env` | Environment variables for Django |
| `/path/to/db.sqlite3` | `/app/db.sqlite3` | Persistent database storage |
| `/path/to/media` | `/app/media` | User-uploaded files |
| `/path/to/ssl/certs` | `/etc/nginx/ssl/certs` | Custom SSL certificates (optional) |
| `/path/to/ssl/private` | `/etc/nginx/ssl/private` | Custom SSL private keys (optional) |

Example with all volumes:

```bash
docker run -p 80:80 -p 443:443 \
  -e DJANGO_ENV=production \
  -v /path/to/.env:/app/.env \
  -v /path/to/db.sqlite3:/app/db.sqlite3 \
  -v /path/to/media:/app/media \
  -v /path/to/ssl/certs:/etc/nginx/ssl/certs \
  -v /path/to/ssl/private:/etc/nginx/ssl/private \
  senzoearl/blognificent:2.0
```

## Building the Image Locally

If you want to build the image locally instead of pulling from Docker Hub:

```bash
# Clone the repository
git clone https://github.com/SenzoEarl/blognificent.git
cd blognificent

# Make the build script executable (Linux/macOS)
chmod +x build_and_push.sh

# Build and push (you can modify the script to skip the push)
./build_and_push.sh
```

On Windows, you can run the script using Git Bash or modify it to use PowerShell commands.

## Container Details

The container runs the following services:

1. **Gunicorn**: Serves the Django application on port 8000 (internal only)
2. **Nginx**: Acts as a reverse proxy, serving:
   - Static files directly from `/app/staticfiles/`
   - Media files directly from `/app/media/`
   - All other requests are proxied to Gunicorn

Both services are managed by Supervisor, ensuring they stay running and restart if they crash.

## SSL Certificates

By default, the container generates self-signed SSL certificates for HTTPS. In production, you should:

1. Use real certificates from Let's Encrypt or another provider
2. Mount them as volumes (as shown above)

## Differences from Previous Setup

This new Docker setup differs from the previous one in several ways:

1. **Single Container**: Previously, the application used separate containers for Django and Nginx. Now everything is in one container.
2. **Simplified Deployment**: No need for Docker Compose to run the application.
3. **Consistent Labels**: All Docker labels follow the Open Container Initiative (OCI) standards.
4. **Flexible Modes**: Easy switching between development (HTTP) and production (HTTPS) modes.

## Troubleshooting

### Logs

To view logs from the container:

```bash
# View all logs
docker logs <container_id>

# View Nginx access logs
docker exec <container_id> cat /var/log/nginx/access.log

# View Nginx error logs
docker exec <container_id> cat /var/log/nginx/error.log

# View Gunicorn logs
docker exec <container_id> cat /var/log/gunicorn/access.log
docker exec <container_id> cat /var/log/gunicorn/error.log
```

### Common Issues

1. **Container exits immediately**: Check if the `.env` file is properly mounted and contains all required variables.
2. **Cannot access the site**: Ensure ports 80/443 are not being used by other services on your host.
3. **SSL certificate warnings**: This is normal with self-signed certificates. For production, use proper certificates.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Senzo Maseko - [senzo.e.maseko@gmail.com](mailto:senzo.e.maseko@gmail.com)