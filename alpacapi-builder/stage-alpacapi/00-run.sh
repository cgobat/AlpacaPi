#!/bin/bash -e

# AlpacaPi custom stage - Main installation stage
# This is the main stage that installs AlpacaPi and all dependencies

# Update package lists
on_chroot << EOF
apt-get update
EOF

# Configure apt for parallel downloads
on_chroot << EOF
# Get number of CPU cores for parallel downloads
CORES=\$(nproc)
echo "Configuring apt for parallel downloads using \$CORES cores"

# Configure apt to use all cores for downloads
echo "Acquire::http::Pipeline-Depth 10;" >> /etc/apt/apt.conf.d/99parallel
echo "Acquire::http::Max-Age 300;" >> /etc/apt/apt.conf.d/99parallel
echo "Acquire::ftp::Timeout 10;" >> /etc/apt/apt.conf.d/99parallel
echo "Acquire::http::Timeout 10;" >> /etc/apt/apt.conf.d/99parallel
echo "Acquire::https::Timeout 10;" >> /etc/apt/apt.conf.d/99parallel
EOF

# Install additional packages if needed
on_chroot << EOF
apt-get install -y \
    hostapd \
    dnsmasq \
    haveged \
    avahi-utils \
    gphoto2 \
    aptitude
EOF
