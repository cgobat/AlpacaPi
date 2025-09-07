#!/bin/bash
# Build AlpacaPi custom Raspberry Pi OS images

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PI_GEN_DIR="${SCRIPT_DIR}/pi-gen"
ALPACAPI_DIR="${SCRIPT_DIR}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if pi-gen exists
if [ ! -d "${PI_GEN_DIR}" ]; then
    log_error "pi-gen directory not found: ${PI_GEN_DIR}"
    log_info "Please clone pi-gen first:"
    log_info "  git clone https://github.com/RPi-Distro/pi-gen.git ${PI_GEN_DIR}"
    exit 1
fi

# Check if Docker is available
if ! command -v docker > /dev/null 2>&1; then
    log_error "Docker is not installed or not in PATH"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    log_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

log_step "Setting up AlpacaPi pi-gen build environment"

# Copy AlpacaPi configuration to pi-gen
log_info "Copying AlpacaPi configuration..."
cp "${ALPACAPI_DIR}/pi-gen/config_alpacapi" "${PI_GEN_DIR}/config"

# Copy AlpacaPi stage to pi-gen
log_info "Copying AlpacaPi stage..."
if [ -d "${PI_GEN_DIR}/stage-alpacapi" ]; then
    rm -rf "${PI_GEN_DIR}/stage-alpacapi"
fi
cp -r "${ALPACAPI_DIR}/pi-gen/stage-alpacapi" "${PI_GEN_DIR}/"

# Copy Docker files
log_info "Copying Docker configuration..."
cp -r "${ALPACAPI_DIR}/pi-gen/docker" "${PI_GEN_DIR}/"

# Make scripts executable
chmod +x "${PI_GEN_DIR}/stage-alpacapi"/*.sh
chmod +x "${PI_GEN_DIR}/docker/build-docker-alpacapi.sh"

# Change to pi-gen directory
cd "${PI_GEN_DIR}"

# Run Docker build
log_step "Starting Docker build process"
"${PI_GEN_DIR}/docker/build-docker-alpacapi.sh"

# Check result
if [ $? -eq 0 ]; then
    log_info "AlpacaPi image build completed successfully!"
    
    # Show generated images
    if [ -d "deploy" ]; then
        log_info "Generated images:"
        ls -la deploy/
        
        # Show image information
        for img in deploy/*.img; do
            if [ -f "$img" ]; then
                log_info "Image: $(basename "$img")"
                log_info "  Size: $(du -h "$img" | cut -f1)"
                log_info "  Location: $img"
            fi
        done
    fi
    
    log_info "You can now flash these images to SD cards for your Raspberry Pi!"
    log_info "Use tools like Raspberry Pi Imager or dd to write the images."
else
    log_error "Build failed!"
    exit 1
fi
