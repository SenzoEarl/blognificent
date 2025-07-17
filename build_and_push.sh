#!/bin/bash
set -e

# Configuration
IMAGE_NAME="blognificent"
DOCKER_HUB_USERNAME="senzoearl"  # Replace with your Docker Hub username
VERSION="2.0"
DOCKERFILE="Dockerfile.combined"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display messages
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    error "Docker is not installed or not in PATH"
fi

# Check if user is logged in to Docker Hub
log "Checking Docker Hub authentication..."
if ! docker info | grep -q "Username"; then
    warn "Not logged in to Docker Hub. Please log in:"
    docker login || error "Failed to log in to Docker Hub"
else
    log "Already logged in to Docker Hub"
fi

# Build the Docker image
log "Building Docker image: ${IMAGE_NAME}:${VERSION}..."
docker build -t ${IMAGE_NAME}:${VERSION} -f ${DOCKERFILE} . || error "Failed to build Docker image"
log "Docker image built successfully"

# Tag the image with Docker Hub username
FULL_IMAGE_NAME="${DOCKER_HUB_USERNAME}/${IMAGE_NAME}"
log "Tagging image as ${FULL_IMAGE_NAME}:${VERSION}..."
docker tag ${IMAGE_NAME}:${VERSION} ${FULL_IMAGE_NAME}:${VERSION} || error "Failed to tag image"
docker tag ${IMAGE_NAME}:${VERSION} ${FULL_IMAGE_NAME}:latest || error "Failed to tag image as latest"

# Push the image to Docker Hub
log "Pushing image to Docker Hub..."
docker push ${FULL_IMAGE_NAME}:${VERSION} || error "Failed to push image"
docker push ${FULL_IMAGE_NAME}:latest || error "Failed to push latest tag"

log "Successfully built and pushed ${FULL_IMAGE_NAME}:${VERSION} and ${FULL_IMAGE_NAME}:latest to Docker Hub"

# Display usage instructions
echo ""
echo "=== How to use this image ==="
echo "1. Pull the image from Docker Hub:"
echo "   docker pull ${FULL_IMAGE_NAME}:${VERSION}"
echo ""
echo "2. Run the container:"
echo "   docker run -p 80:80 -p 443:443 -e DJANGO_ENV=production -v /path/to/.env:/app/.env ${FULL_IMAGE_NAME}:${VERSION}"
echo ""
echo "3. For development mode (HTTP only):"
echo "   docker run -p 80:80 -e DJANGO_ENV=development -v /path/to/.env:/app/.env ${FULL_IMAGE_NAME}:${VERSION}"
echo ""
echo "4. To create a superuser during container startup, add these environment variables:"
echo "   -e DJANGO_SUPERUSER_USERNAME=admin -e DJANGO_SUPERUSER_PASSWORD=password -e DJANGO_SUPERUSER_EMAIL=admin@example.com"
echo ""