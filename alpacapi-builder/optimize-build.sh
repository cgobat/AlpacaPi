#!/bin/bash

# AlpacaPi Build Optimization Script
# This script optimizes the build environment for maximum parallel processing

echo "🚀 Optimizing AlpacaPi build environment for maximum performance..."

# Get number of CPU cores and threads
CORES=$(nproc)
THREADS=$(nproc)
echo "📊 Detected $CORES CPU cores ($THREADS threads)"

# Detect if this is a high-core system (Threadripper, Xeon, etc.)
if [ $CORES -ge 16 ]; then
    echo "🔥 High-core system detected! Optimizing for maximum performance..."
    # For very high core systems, we can be more aggressive
    PARALLEL_JOBS=$((CORES * 2))  # Use 2x cores for I/O bound tasks
    MAKE_JOBS=$CORES              # Use all cores for CPU bound tasks
    PIP_JOBS=$((CORES * 2))       # Use 2x cores for pip installs
else
    PARALLEL_JOBS=$CORES
    MAKE_JOBS=$CORES
    PIP_JOBS=$CORES
fi

echo "⚡ Using $MAKE_JOBS cores for compilation"
echo "⚡ Using $PARALLEL_JOBS parallel jobs for I/O tasks"
echo "⚡ Using $PIP_JOBS parallel jobs for pip installs"

# Configure system for parallel processing
echo "⚙️  Configuring system for parallel processing..."

# Set environment variables
export MAKEFLAGS="-j$MAKE_JOBS"
export MAKEOPTS="-j$MAKE_JOBS"
export PARALLEL_JOBS="$PARALLEL_JOBS"
export CCACHE_DIR="/tmp/ccache"
export CCACHE_MAXSIZE="4G"  # Larger cache for high-core systems
export CCACHE_COMPRESS=1    # Compress cache for better I/O
export CCACHE_SLOPPINESS="pch_defines,time_macros"

# Create ccache directory
mkdir -p "$CCACHE_DIR"

# Configure ccache
if command -v ccache &> /dev/null; then
    ccache -M 4G
    ccache -s
    echo "✅ ccache configured for faster compilation"
else
    echo "⚠️  ccache not found, installing..."
    sudo apt-get update
    sudo apt-get install -y ccache
    ccache -M 4G
    ccache -s
fi

# Configure ccache for high-core systems
if [ $CORES -ge 16 ]; then
    echo "🔥 Configuring ccache for high-core system..."
    ccache -M 8G  # Even larger cache for Threadripper
    ccache -o compression=1
    ccache -o sloppiness=pch_defines,time_macros
    ccache -o max_files=100000
    ccache -s
fi

# Configure Docker for parallel builds
echo "🐳 Configuring Docker for parallel builds..."

# Set Docker buildkit for parallel builds
export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain

# Configure Docker daemon for better performance
if [ $CORES -ge 16 ]; then
    echo "🔥 Configuring Docker for high-core system..."
    sudo tee /etc/docker/daemon.json > /dev/null << 'DOCKER_EOF'
{
    "max-concurrent-downloads": 20,
    "max-concurrent-uploads": 20,
    "storage-driver": "overlay2",
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "default-ulimits": {
        "memlock": {
            "Name": "memlock",
            "Hard": -1,
            "Soft": -1
        }
    },
    "shm-size": "2g"
}
DOCKER_EOF
else
    sudo tee /etc/docker/daemon.json > /dev/null << 'DOCKER_EOF'
{
    "max-concurrent-downloads": 10,
    "max-concurrent-uploads": 10,
    "storage-driver": "overlay2",
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    }
}
DOCKER_EOF
fi

# Restart Docker daemon
sudo systemctl restart docker

echo "✅ Docker configured for parallel processing"

# Configure system limits for parallel builds
echo "🔧 Configuring system limits..."

# Increase file descriptor limits
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# Configure kernel parameters for better performance
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
echo "vm.dirty_ratio=15" | sudo tee -a /etc/sysctl.conf
echo "vm.dirty_background_ratio=5" | sudo tee -a /etc/sysctl.conf

# Apply sysctl changes
sudo sysctl -p

echo "✅ System limits configured"

# Configure apt for parallel downloads
echo "📦 Configuring apt for parallel downloads..."

sudo tee /etc/apt/apt.conf.d/99parallel > /dev/null << 'APT_EOF'
Acquire::http::Pipeline-Depth 10;
Acquire::http::Max-Age 300;
Acquire::ftp::Timeout 10;
Acquire::http::Timeout 10;
Acquire::https::Timeout 10;
APT_EOF

echo "✅ apt configured for parallel downloads"

# Configure pip for parallel processing
echo "🐍 Configuring pip for parallel processing..."

mkdir -p ~/.pip
cat > ~/.pip/pip.conf << 'PIP_EOF'
[global]
cache-dir = /tmp/pip-cache
timeout = 60
retries = 3
[install]
upgrade = true
PIP_EOF

echo "✅ pip configured for parallel processing"

# Additional optimizations for high-core systems
if [ $CORES -ge 16 ]; then
    echo "🔥 Applying additional high-core optimizations..."

    # Configure system limits for high-core builds
    echo "* soft nofile 131072" | sudo tee -a /etc/security/limits.conf
    echo "* hard nofile 131072" | sudo tee -a /etc/security/limits.conf
    echo "* soft nproc 131072" | sudo tee -a /etc/security/limits.conf
    echo "* hard nproc 131072" | sudo tee -a /etc/security/limits.conf

    # Optimize kernel parameters for high-core systems
    echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
    echo "kernel.pid_max=4194304" | sudo tee -a /etc/sysctl.conf
    echo "fs.file-max=2097152" | sudo tee -a /etc/sysctl.conf

    # Apply sysctl changes
    sudo sysctl -p

    # Configure pip for high-core systems
    mkdir -p ~/.pip
    cat > ~/.pip/pip.conf << 'PIP_EOF'
[global]
cache-dir = /tmp/pip-cache
timeout = 60
retries = 3
[install]
upgrade = true
[build]
parallel = true
PIP_EOF

    echo "✅ High-core system optimizations applied"
fi

# Summary
echo ""
echo "🎉 Build optimization complete!"
echo "📊 Configuration:"
echo "   • CPU Cores: $CORES"
echo "   • Make jobs: $MAKE_JOBS"
echo "   • Parallel jobs: $PARALLEL_JOBS"
echo "   • ccache: 4GB (8GB for high-core systems)"
echo "   • Docker: BuildKit enabled with high-core optimizations"
echo "   • Parallel downloads: enabled"
if [ $CORES -ge 16 ]; then
    echo "   • High-core optimizations: ENABLED"
fi
echo ""
echo "🚀 Ready to build AlpacaPi with maximum performance!"
echo "   Run: cd alpacapi-builder && ./build_arm64.sh"
