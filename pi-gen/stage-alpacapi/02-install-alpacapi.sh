#!/bin/bash
# Install AlpacaPi from source

set -e

echo "Installing AlpacaPi..."

# Create AlpacaPi directory
mkdir -p /opt/alpacapi
cd /opt/alpacapi

# Clone AlpacaPi repository
echo "Cloning AlpacaPi repository..."
git clone https://github.com/your-username/AlpacaPi.git .

# Create build directory
mkdir -p build
cd build

# Configure with CMake (server-only build)
echo "Configuring AlpacaPi build..."
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_CLIENT_APPS=OFF \
    -DBUILD_EXAMPLES=ON \
    -DBUILD_TESTS=OFF

# Build AlpacaPi
echo "Building AlpacaPi..."
make -j$(nproc)

# Install AlpacaPi
echo "Installing AlpacaPi..."
make install

# Create AlpacaPi user
useradd -r -s /bin/false -d /opt/alpacapi alpacapi

# Set permissions
chown -R alpacapi:alpacapi /opt/alpacapi
chmod +x /opt/alpacapi/build/alpacapi

# Create log directory
mkdir -p /var/log/alpacapi
chown alpacapi:alpacapi /var/log/alpacapi

echo "AlpacaPi installed successfully"
