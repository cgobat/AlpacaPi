#!/bin/bash
# Build AlpacaPi custom Raspberry Pi OS images using Docker

set -e

# Configuration
DOCKER_IMAGE="pi-gen-alpacapi"
DOCKER_CONTAINER="pigen_work_alpacapi"
BUILD_DIR="/pi-gen"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    log_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if config file exists
if [ ! -f "${BUILD_DIR}/config_alpacapi" ]; then
    log_error "Configuration file not found: ${BUILD_DIR}/config_alpacapi"
    exit 1
fi

# Copy config file
log_info "Setting up configuration..."
cp "${BUILD_DIR}/config_alpacapi" "${BUILD_DIR}/config"

# Build Docker image if it doesn't exist
if ! docker image inspect "${DOCKER_IMAGE}" > /dev/null 2>&1; then
    log_info "Building Docker image: ${DOCKER_IMAGE}"
    docker build -f "${BUILD_DIR}/docker/Dockerfile.alpacapi" -t "${DOCKER_IMAGE}" "${BUILD_DIR}/docker/"
fi

# Remove existing container if it exists
if docker container inspect "${DOCKER_CONTAINER}" > /dev/null 2>&1; then
    log_info "Removing existing container: ${DOCKER_CONTAINER}"
    docker rm -f "${DOCKER_CONTAINER}" > /dev/null 2>&1
fi

# Create work container
log_info "Creating work container: ${DOCKER_CONTAINER}"
docker run -d --name "${DOCKER_CONTAINER}" \
    --privileged \
    --volume "${BUILD_DIR}:/pi-gen" \
    --volume /dev:/dev \
    --cap-add=ALL \
    "${DOCKER_IMAGE}" \
    sleep infinity

# Wait for container to be ready
sleep 5

# Run the build
log_info "Starting AlpacaPi image build..."
docker exec -it "${DOCKER_CONTAINER}" /pi-gen/build.sh

# Check build result
if [ $? -eq 0 ]; then
    log_info "Build completed successfully!"
    log_info "Images are available in: ${BUILD_DIR}/deploy/"
    
    # List generated images
    if [ -d "${BUILD_DIR}/deploy" ]; then
        log_info "Generated images:"
        ls -la "${BUILD_DIR}/deploy/"
    fi
else
    log_error "Build failed!"
    exit 1
fi

# Ask if user wants to keep the container
read -p "Do you want to keep the build container for debugging? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Removing build container: ${DOCKER_CONTAINER}"
    docker rm -f "${DOCKER_CONTAINER}" > /dev/null 2>&1
else
    log_info "Container kept: ${DOCKER_CONTAINER}"
    log_info "To enter the container: docker exec -it ${DOCKER_CONTAINER} /bin/bash"
fi

log_info "AlpacaPi image build process completed!"
