#!/bin/bash
# Configure AlpacaPi

set -e

echo "Configuring AlpacaPi..."

# Create AlpacaPi configuration directory
mkdir -p /etc/alpacapi

# Create default configuration file
cat > /etc/alpacapi/alpacapi.conf << 'EOF'
# AlpacaPi Configuration File

# Server settings
SERVER_PORT=6800
DISCOVERY_PORT=32227
LOG_LEVEL=INFO
LOG_FILE=/var/log/alpacapi/alpacapi.log

# Device settings
AUTO_DISCOVERY=1
DEVICE_TIMEOUT=30

# Network settings
BIND_ADDRESS=0.0.0.0
ALLOWED_IPS=192.168.0.0/16,10.0.0.0/8,172.16.0.0/12

# Driver settings
ENABLE_ZWO=1
ENABLE_ATIK=1
ENABLE_QHY=1
ENABLE_QSI=0
ENABLE_TOUPTEK=0
ENABLE_FLIR=0
ENABLE_SONY=0
ENABLE_MOONLITE=1
ENABLE_TELESCOPE_MOUNTS=1
ENABLE_OBSERVATORY=0
EOF

# Set permissions
chown alpacapi:alpacapi /etc/alpacapi/alpacapi.conf
chmod 644 /etc/alpacapi/alpacapi.conf

# Create systemd service file
cat > /etc/systemd/system/alpacapi.service << 'EOF'
[Unit]
Description=AlpacaPi ASCOM Alpaca Server
After=network.target
Wants=network.target

[Service]
Type=simple
User=alpacapi
Group=alpacapi
WorkingDirectory=/opt/alpacapi
ExecStart=/opt/alpacapi/build/alpacapi
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=alpacapi

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/log/alpacapi /tmp

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
systemctl enable alpacapi.service

# Create udev rules directory
mkdir -p /etc/udev/rules.d

# Add common udev rules for astronomy devices
cat > /etc/udev/rules.d/99-astronomy-devices.rules << 'EOF'
# ZWO ASI Cameras
SUBSYSTEM=="usb", ATTRS{idVendor}=="03c3", MODE="0666", GROUP="plugdev"

# ATIK Cameras
SUBSYSTEM=="usb", ATTRS{idVendor}=="04b4", MODE="0666", GROUP="plugdev"

# QHY Cameras
SUBSYSTEM=="usb", ATTRS{idVendor}=="1618", MODE="0666", GROUP="plugdev"

# QSI Cameras
SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0666", GROUP="plugdev"

# Touptek Cameras
SUBSYSTEM=="usb", ATTRS{idVendor}=="1e4e", MODE="0666", GROUP="plugdev"

# Moonlite Focusers
SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0666", GROUP="plugdev"

# Generic USB Serial devices
SUBSYSTEM=="tty", ATTRS{interface}=="*Serial*", MODE="0666", GROUP="plugdev"
EOF

# Add pi user to plugdev group
usermod -a -G plugdev pi

echo "AlpacaPi configured successfully"
