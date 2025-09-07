#!/bin/bash
# Setup script for AlpacaPi pi-gen integration

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALPACAPI_DIR="$(dirname "${SCRIPT_DIR}")"
PI_GEN_DIR="${SCRIPT_DIR}/pi-gen"

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

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    # Check if Docker is installed
    if ! command -v docker > /dev/null 2>&1; then
        log_error "Docker is not installed. Please install Docker first."
        log_info "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    
    # Check if Git is installed
    if ! command -v git > /dev/null 2>&1; then
        log_error "Git is not installed. Please install Git first."
        exit 1
    fi
    
    log_info "Prerequisites check passed"
}

# Clone pi-gen repository
clone_pi_gen() {
    log_step "Setting up pi-gen repository..."
    
    if [ -d "${PI_GEN_DIR}" ]; then
        log_warn "pi-gen directory already exists: ${PI_GEN_DIR}"
        read -p "Do you want to remove it and re-clone? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Removing existing pi-gen directory..."
            rm -rf "${PI_GEN_DIR}"
        else
            log_info "Using existing pi-gen directory"
            return 0
        fi
    fi
    
    log_info "Cloning pi-gen repository..."
    git clone https://github.com/RPi-Distro/pi-gen.git "${PI_GEN_DIR}"
    
    log_info "pi-gen repository cloned successfully"
}

# Setup AlpacaPi integration
setup_alpacapi_integration() {
    log_step "Setting up AlpacaPi integration..."
    
    # Copy AlpacaPi configuration
    log_info "Copying AlpacaPi configuration..."
    cp "${SCRIPT_DIR}/config_alpacapi" "${PI_GEN_DIR}/config"
    
    # Copy AlpacaPi stage
    log_info "Copying AlpacaPi stage..."
    if [ -d "${PI_GEN_DIR}/stage-alpacapi" ]; then
        rm -rf "${PI_GEN_DIR}/stage-alpacapi"
    fi
    cp -r "${SCRIPT_DIR}/stage-alpacapi" "${PI_GEN_DIR}/"
    
    # Copy Docker files
    log_info "Copying Docker configuration..."
    cp -r "${SCRIPT_DIR}/docker" "${PI_GEN_DIR}/"
    
    # Make scripts executable
    log_info "Setting executable permissions..."
    chmod +x "${PI_GEN_DIR}/stage-alpacapi"/*.sh
    chmod +x "${PI_GEN_DIR}/docker/build-docker-alpacapi.sh"
    chmod +x "${PI_GEN_DIR}/build-alpacapi.sh"
    
    log_info "AlpacaPi integration setup completed"
}

# Create build script
create_build_script() {
    log_step "Creating build script..."
    
    cat > "${PI_GEN_DIR}/build-alpacapi.sh" << 'EOF'
#!/bin/bash
# Build AlpacaPi custom Raspberry Pi OS images

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    log_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Run Docker build
log_step "Starting AlpacaPi image build..."
"${SCRIPT_DIR}/docker/build-docker-alpacapi.sh"

# Check result
if [ $? -eq 0 ]; then
    log_info "AlpacaPi image build completed successfully!"
    
    # Show generated images
    if [ -d "deploy" ]; then
        log_info "Generated images:"
        ls -la deploy/
    fi
else
    log_error "Build failed!"
    exit 1
fi
EOF
    
    chmod +x "${PI_GEN_DIR}/build-alpacapi.sh"
    log_info "Build script created"
}

# Main execution
main() {
    echo "AlpacaPi pi-gen Setup Script"
    echo "============================"
    echo
    
    check_prerequisites
    clone_pi_gen
    setup_alpacapi_integration
    create_build_script
    
    echo
    log_info "Setup completed successfully!"
    echo
    log_info "Next steps:"
    log_info "1. Edit configuration: ${PI_GEN_DIR}/config"
    log_info "2. Customize drivers: ${PI_GEN_DIR}/stage-alpacapi/02-install-alpacapi.sh"
    log_info "3. Build image: cd ${PI_GEN_DIR} && ./build-alpacapi.sh"
    echo
    log_info "For more information, see: ${SCRIPT_DIR}/README_ALPACAPI.md"
}

# Run main function
main "$@"
