#!/bin/bash -e

# AlpacaPi dependencies installation - Stage 0
# Install build dependencies and configure for parallel processing

# Update package lists
on_chroot << EOF
apt-get update
EOF

# Configure system for maximum parallel processing
on_chroot << EOF
# Get number of CPU cores
CORES=\$(nproc)
echo "Configuring system for parallel processing using \$CORES cores"

# Configure make to use all cores
echo "MAKEFLAGS=-j\$CORES" >> /etc/environment

# Configure ccache for faster compilation
apt-get install -y ccache
export PATH="/usr/lib/ccache:\$PATH"
echo 'export PATH="/usr/lib/ccache:\$PATH"' >> /etc/environment

# Configure ccache settings
ccache -M 2G
ccache -s

# Configure apt for parallel downloads
echo "Acquire::http::Pipeline-Depth 10;" >> /etc/apt/apt.conf.d/99parallel
echo "Acquire::http::Max-Age 300;" >> /etc/apt/apt.conf.d/99parallel
echo "Acquire::ftp::Timeout 10;" >> /etc/apt/apt.conf.d/99parallel
echo "Acquire::http::Timeout 10;" >> /etc/apt/apt.conf.d/99parallel
echo "Acquire::https::Timeout 10;" >> /etc/apt/apt.conf.d/99parallel

# Configure pip for parallel processing
mkdir -p /root/.pip
cat > /root/.pip/pip.conf << 'PIP_EOF'
[global]
cache-dir = /tmp/pip-cache
timeout = 60
retries = 3
PIP_EOF

# Configure environment for parallel builds
echo "export MAKEFLAGS=-j\$CORES" >> /etc/environment
echo "export MAKEOPTS=-j\$CORES" >> /etc/environment
EOF

# Install build dependencies
on_chroot << EOF
# Get number of CPU cores
CORES=\$(nproc)
echo "Installing build dependencies using \$CORES cores"

# Install essential build tools
apt-get install -y \
    build-essential \
    cmake \
    git \
    pkg-config \
    ccache \
    ninja-build \
    make \
    gcc \
    g++ \
    libc6-dev \
    libstdc++6 \
    libgcc-s1 \
    libc6 \
    libgomp1 \
    libatomic1 \
    libasan6 \
    libtsan0 \
    libubsan1 \
    libgcc-12-dev \
    libstdc++-12-dev
EOF