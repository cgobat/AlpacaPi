#!/bin/bash
# Install AlpacaPi from source using npm build system

set -e

echo "Installing AlpacaPi..."

# Create AlpacaPi directory
mkdir -p /opt/alpacapi
cd /opt/alpacapi

# Clone AlpacaPi repository
echo "Cloning AlpacaPi repository..."
git clone https://github.com/open-astro/AlpacaPi.git .

# Install npm dependencies
echo "Installing npm dependencies..."
npm install

# Build AlpacaPi using npm build system
echo "Building AlpacaPi..."
npm run build:pi

# Install AlpacaPi system-wide
echo "Installing AlpacaPi system-wide..."
cp -r build/* /usr/local/bin/
cp -r src/* /usr/local/share/alpacapi/

# Create AlpacaPi user
useradd -r -s /bin/false -d /opt/alpacapi alpacapi

# Set permissions
chown -R alpacapi:alpacapi /opt/alpacapi
chmod +x /opt/alpacapi/build/alpacapi

# Create log directory
mkdir -p /var/log/alpacapi
chown alpacapi:alpacapi /var/log/alpacapi

echo "AlpacaPi installed successfully"
