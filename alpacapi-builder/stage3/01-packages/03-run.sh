#!/bin/bash -e

# AlpacaPi installation - Stage 3
# Configure systemd services and final setup

# Create systemd service for AlpacaPi
install -m 644 files/alpacapi.service "${ROOTFS_DIR}/etc/systemd/system/"

# Enable the service
on_chroot << EOF
systemctl enable alpacapi.service
EOF

# Create startup script
install -m 755 files/alpacapi_start.sh "${ROOTFS_DIR}/usr/bin/"

# Set up permissions
on_chroot << EOF
chmod +x /usr/bin/alpacapi_start.sh
chown -R alpacapi:alpacapi /home/alpacapi/AlpacaPi
chown -R alpacapi:alpacapi /home/alpacapi/.config/alpacapi
EOF
