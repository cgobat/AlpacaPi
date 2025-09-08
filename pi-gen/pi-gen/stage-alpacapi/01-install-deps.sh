#!/bin/bash
# Install system dependencies for AlpacaPi

set -e

echo "Installing system dependencies for AlpacaPi..."

# Update package lists
apt-get update

# Install essential build tools
apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    unzip \
    pkg-config

# Install system libraries
apt-get install -y \
    libusb-1.0-0-dev \
    libudev-dev \
    libi2c-dev \
    libcfitsio-dev \
    libjpeg-dev \
    libpng-dev \
    libssl-dev \
    libffi-dev

# Install Node.js 18+ and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install Python dependencies (if needed)
apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-setuptools

# Install network tools
apt-get install -y \
    net-tools \
    iputils-ping \
    dnsutils \
    nmap

# Install development tools
apt-get install -y \
    vim \
    nano \
    htop \
    tree \
    jq

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "System dependencies installed successfully"
