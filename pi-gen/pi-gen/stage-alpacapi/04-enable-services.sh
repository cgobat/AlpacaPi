#!/bin/bash
# Enable services and final configuration

set -e

echo "Enabling services and final configuration..."

# Enable SSH if configured
if [ "${ENABLE_SSH}" = "1" ]; then
    systemctl enable ssh
    echo "SSH enabled"
fi

# Enable VNC if configured
if [ "${ENABLE_VNC}" = "1" ]; then
    systemctl enable vncserver-x11-serviced
    echo "VNC enabled"
fi

# Configure network interfaces
cat > /etc/dhcpcd.conf << 'EOF'
# AlpacaPi Network Configuration

# Static IP configuration (uncomment and modify as needed)
#interface eth0
#static ip_address=192.168.1.100/24
#static routers=192.168.1.1
#static domain_name_servers=192.168.1.1 8.8.8.8

# WiFi configuration (uncomment and modify as needed)
#interface wlan0
#static ip_address=192.168.1.101/24
#static routers=192.168.1.1
#static domain_name_servers=192.168.1.1 8.8.8.8

# Enable IPv4LL
option rapid_commit

# A single client ID to be shared between DHCPv4 and DHCPv6
clientid

# A hook script is provided to lookup the hostname if not set by the DHCP
# server, but it should not be run unless there is no /etc/hostname file.
nohook lookup-hostname
EOF

# Create startup script
cat > /usr/local/bin/alpacapi-startup.sh << 'EOF'
#!/bin/bash
# AlpacaPi startup script

echo "Starting AlpacaPi services..."

# Wait for network
while ! ping -c 1 8.8.8.8 > /dev/null 2>&1; do
    echo "Waiting for network..."
    sleep 5
done

# Start AlpacaPi service
systemctl start alpacapi

# Display status
echo "AlpacaPi status:"
systemctl status alpacapi --no-pager

# Display network information
echo "Network configuration:"
ip addr show

echo "AlpacaPi should be discoverable on port 6800"
echo "Discovery service on port 32227"
EOF

chmod +x /usr/local/bin/alpacapi-startup.sh

# Add to rc.local for startup
cat > /etc/rc.local << 'EOF'
#!/bin/bash
# AlpacaPi startup

# Run AlpacaPi startup script
/usr/local/bin/alpacapi-startup.sh

exit 0
EOF

chmod +x /etc/rc.local

# Create welcome message
cat > /etc/motd << 'EOF'
Welcome to AlpacaPi!

This Raspberry Pi is configured with AlpacaPi for NINA control.

Services:
- AlpacaPi Server: Port 6800
- Discovery Service: Port 32227
- SSH: Enabled

To check status:
  sudo systemctl status alpacapi

To view logs:
  sudo journalctl -u alpacapi -f

To restart AlpacaPi:
  sudo systemctl restart alpacapi

For more information, visit: https://github.com/your-username/AlpacaPi
EOF

# Create desktop shortcut (if desktop enabled)
if [ "${ENABLE_DESKTOP}" = "1" ]; then
    mkdir -p /home/pi/Desktop
    cat > /home/pi/Desktop/AlpacaPi.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=AlpacaPi
Comment=AlpacaPi Server Control
Exec=lxterminal -e "sudo systemctl status alpacapi"
Icon=applications-system
Terminal=false
Categories=System;
EOF
    chown pi:pi /home/pi/Desktop/AlpacaPi.desktop
    chmod +x /home/pi/Desktop/AlpacaPi.desktop
fi

echo "Services enabled and configured successfully"
