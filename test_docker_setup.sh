#!/bin/bash
set -e

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
    ERRORS=$((ERRORS+1))
}

# Initialize error counter
ERRORS=0
WARNINGS=0

log "Starting Docker setup validation..."

# Check if required files exist
log "Checking for required files..."
FILES=(
    "Dockerfile.combined"
    "supervisord.conf"
    "entrypoint.sh"
    "build_and_push.sh"
    "DOCKER.md"
    "nginx/nginx.conf"
    "nginx/nginx.dev.conf"
    "requirements.txt"
)

for FILE in "${FILES[@]}"; do
    if [ ! -f "$FILE" ]; then
        error "Missing required file: $FILE"
    else
        log "Found file: $FILE"
    fi
done

# Check if entrypoint.sh is executable
if [ -f "entrypoint.sh" ] && [ ! -x "entrypoint.sh" ]; then
    warn "entrypoint.sh is not executable. Run: chmod +x entrypoint.sh"
    WARNINGS=$((WARNINGS+1))
fi

# Check if build_and_push.sh is executable
if [ -f "build_and_push.sh" ] && [ ! -x "build_and_push.sh" ]; then
    warn "build_and_push.sh is not executable. Run: chmod +x build_and_push.sh"
    WARNINGS=$((WARNINGS+1))
fi

# Validate Dockerfile.combined
if [ -f "Dockerfile.combined" ]; then
    log "Validating Dockerfile.combined..."
    
    # Check for required base image
    if ! grep -q "FROM python:" "Dockerfile.combined"; then
        error "Dockerfile.combined does not specify a Python base image"
    fi
    
    # Check for Nginx installation
    if ! grep -q "nginx" "Dockerfile.combined"; then
        error "Dockerfile.combined does not install Nginx"
    fi
    
    # Check for supervisor installation
    if ! grep -q "supervisor" "Dockerfile.combined"; then
        error "Dockerfile.combined does not install supervisor"
    fi
    
    # Check for EXPOSE directives
    if ! grep -q "EXPOSE 80" "Dockerfile.combined"; then
        error "Dockerfile.combined does not expose port 80"
    fi
    
    if ! grep -q "EXPOSE 443" "Dockerfile.combined"; then
        error "Dockerfile.combined does not expose port 443"
    fi
    
    # Check for LABEL directives
    if ! grep -q "LABEL maintainer=" "Dockerfile.combined"; then
        error "Dockerfile.combined does not have a maintainer label"
    fi
    
    if ! grep -q "org.opencontainers.image.title" "Dockerfile.combined"; then
        error "Dockerfile.combined does not have an image title label"
    fi
    
    if ! grep -q "org.opencontainers.image.version" "Dockerfile.combined"; then
        error "Dockerfile.combined does not have an image version label"
    fi
fi

# Validate supervisord.conf
if [ -f "supervisord.conf" ]; then
    log "Validating supervisord.conf..."
    
    # Check for required sections
    if ! grep -q "\[supervisord\]" "supervisord.conf"; then
        error "supervisord.conf does not have a [supervisord] section"
    fi
    
    if ! grep -q "\[program:gunicorn\]" "supervisord.conf"; then
        error "supervisord.conf does not have a [program:gunicorn] section"
    fi
    
    if ! grep -q "\[program:nginx\]" "supervisord.conf"; then
        error "supervisord.conf does not have a [program:nginx] section"
    fi
fi

# Validate entrypoint.sh
if [ -f "entrypoint.sh" ]; then
    log "Validating entrypoint.sh..."
    
    # Check for shebang
    if ! head -n 1 "entrypoint.sh" | grep -q "#!/bin/bash"; then
        warn "entrypoint.sh does not start with #!/bin/bash"
        WARNINGS=$((WARNINGS+1))
    fi
    
    # Check for exec "$@" at the end
    if ! grep -q "exec \"\$@\"" "entrypoint.sh"; then
        error "entrypoint.sh does not have exec \"\$@\" to pass arguments"
    fi
    
    # Check for development/production mode handling
    if ! grep -q "DJANGO_ENV" "entrypoint.sh"; then
        warn "entrypoint.sh does not check for DJANGO_ENV environment variable"
        WARNINGS=$((WARNINGS+1))
    fi
fi

# Validate nginx configurations
if [ -f "nginx/nginx.conf" ] && [ -f "nginx/nginx.dev.conf" ]; then
    log "Validating Nginx configurations..."
    
    # Check for proxy_pass in production config
    if ! grep -q "proxy_pass http://web:8000;" "nginx/nginx.conf"; then
        warn "nginx.conf still points to web:8000 instead of localhost:8000"
        WARNINGS=$((WARNINGS+1))
    fi
    
    # Check for proxy_pass in development config
    if ! grep -q "proxy_pass http://web:8000;" "nginx/nginx.dev.conf"; then
        warn "nginx.dev.conf still points to web:8000 instead of localhost:8000"
        WARNINGS=$((WARNINGS+1))
    fi
    
    # Check for SSL configuration in production
    if ! grep -q "ssl_certificate" "nginx/nginx.conf"; then
        warn "nginx.conf does not have SSL certificate configuration"
        WARNINGS=$((WARNINGS+1))
    fi
fi

# Summary
log "Validation complete!"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    log "All checks passed! The Docker setup looks good."
else
    if [ $ERRORS -gt 0 ]; then
        error "Found $ERRORS error(s). Please fix them before building the Docker image."
    fi
    
    if [ $WARNINGS -gt 0 ]; then
        warn "Found $WARNINGS warning(s). Consider addressing them for optimal setup."
    fi
fi

# Note about actual testing
echo ""
echo "NOTE: This script only validates the configuration files and does not actually build or run the Docker image."
echo "To fully test the setup, you should run the build_and_push.sh script and test the resulting image."
echo ""

# Exit with error code if there were errors
if [ $ERRORS -gt 0 ]; then
    exit 1
fi

exit 0