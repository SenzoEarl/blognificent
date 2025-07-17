# How to Run Blognificent

This document provides instructions for running the Blognificent project in different environments.

## Prerequisites

- Docker and Docker Compose installed
- Git (to clone the repository)

## Option 1: Run with HTTP (Development)

This method runs the application with HTTP only (no SSL), which is simpler for development purposes.

1. Clone the repository (if you haven't already):
   ```bash
   git clone https://github.com/SenzoEarl/blognificent.git
   cd blognificent
   ```

2. Make sure the `.env` file exists in the project root with the following variables:
   ```
   DEBUG = False  # or True for development
   SECRET_KEY = 'your_secret_key'
   EMAIL_HOST_USER = 'your_email@gmail.com'
   EMAIL_HOST_PASSWORD = 'your_email_password'
   DEFAULT_FROM_EMAIL = 'Blognificent'
   ```

3. Run the application using the development Docker Compose configuration:
   ```bash
   docker-compose -f docker-compose.dev.yml up -d --build
   ```

4. Access the application at http://localhost

5. To stop the application:
   ```bash
   docker-compose -f docker-compose.dev.yml down
   ```

## Option 2: Run with HTTPS (Production-like)

This method runs the application with HTTPS, which is more secure and closer to a production environment.

1. Clone the repository (if you haven't already):
   ```bash
   git clone https://github.com/SenzoEarl/blognificent.git
   cd blognificent
   ```

2. Make sure the `.env` file exists in the project root with the necessary variables (as described above).

3. Generate SSL certificates:
   
   **On Linux/macOS:**
   ```bash
   cd ssl
   chmod +x generate-certs.sh
   ./generate-certs.sh
   cd ..
   ```
   
   **On Windows:**
   
   Using Git Bash:
   ```bash
   cd ssl
   ./generate-certs.sh
   cd ..
   ```
   
   Or manually with OpenSSL:
   ```bash
   # Create directories if they don't exist
   mkdir -p ssl/certs
   mkdir -p ssl/private
   
   # Generate a private key
   openssl genrsa -out ssl/private/blognificent.key 2048
   
   # Generate a Certificate Signing Request (CSR)
   openssl req -new -key ssl/private/blognificent.key -out ssl/private/blognificent.csr -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
   
   # Generate a self-signed certificate valid for 365 days
   openssl x509 -req -days 365 -in ssl/private/blognificent.csr -signkey ssl/private/blognificent.key -out ssl/certs/blognificent.crt
   
   # Generate a strong Diffie-Hellman group
   openssl dhparam -out ssl/certs/dhparam.pem 2048
   ```

4. Run the application using the standard Docker Compose configuration:
   ```bash
   docker-compose up -d --build
   ```

5. Access the application at https://localhost

6. To stop the application:
   ```bash
   docker-compose down
   ```

## Accessing the Admin Interface

1. Go to http://localhost/admin/ (or https://localhost/admin/ if using HTTPS)
2. Log in with your superuser credentials

If you haven't created a superuser yet, you can do so with:

```bash
# For the development setup
docker exec -it blognificent python manage.py createsuperuser

# Follow the prompts to create a username, email, and password
```

## Troubleshooting

### SSL Certificate Issues

If you encounter SSL certificate issues:
- Make sure you've generated the certificates as described above
- Your browser might warn about self-signed certificates; you can proceed by accepting the risk

### Port Conflicts

If port 80 or 443 is already in use:
- Modify the port mappings in the docker-compose.yml or docker-compose.dev.yml file
- For example, change "80:80" to "8080:80" to use port 8080 instead

### Container Logs

To view logs for troubleshooting:

```bash
# View Django application logs
docker logs blognificent

# View Nginx logs
docker logs blognificent_nginx
```