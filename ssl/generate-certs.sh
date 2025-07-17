#!/bin/bash
# Script to generate self-signed SSL certificates for development

# Create directories if they don't exist
mkdir -p certs
mkdir -p private

# Generate a private key
openssl genrsa -out private/blognificent.key 2048

# Generate a Certificate Signing Request (CSR)
openssl req -new -key private/blognificent.key -out private/blognificent.csr -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Generate a self-signed certificate valid for 365 days
openssl x509 -req -days 365 -in private/blognificent.csr -signkey private/blognificent.key -out certs/blognificent.crt

# Generate a strong Diffie-Hellman group
openssl dhparam -out certs/dhparam.pem 2048

echo "Self-signed SSL certificates have been generated."
echo "Certificate: certs/blognificent.crt"
echo "Private Key: private/blognificent.key"
echo "DH Params: certs/dhparam.pem"