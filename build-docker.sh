#!/bin/bash
set -e

echo "Starting AlpacaPi build in Docker..."

# Create build directory
mkdir -p build
cd build

# Configure with CMake
echo "Configuring with CMake..."
cmake .. \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DBUILD_CLIENT_APPS=OFF \
    -DBUILD_EXAMPLES=ON \
    -DBUILD_TESTS=OFF

# Build
echo "Building AlpacaPi..."
make -j$(nproc)

# Fix permissions for copying
echo "Fixing permissions..."
chown -R 1000:1000 /workspace/build 2>/dev/null || true

echo "Build completed successfully!"
