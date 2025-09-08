#!/bin/bash -e

# AlpacaPi prerun script
# This script runs before the main installation

# Create alpacapi user if it doesn't exist
if ! id "alpacapi" &>/dev/null; then
    useradd -m -s /bin/bash alpacapi
    echo "alpacapi:alpacapi" | chpasswd
    usermod -aG sudo alpacapi
fi

# Create necessary directories
mkdir -p /home/alpacapi/AlpacaPi
mkdir -p /home/alpacapi/.config/alpacapi
