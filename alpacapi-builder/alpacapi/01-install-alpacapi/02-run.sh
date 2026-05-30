#!/bin/bash -e

# AlpacaPi installation - Stage 2
# Clone and build AlpacaPi from source

# Set working directory
ALPACAPI_DIR="/home/alpacapi/AlpacaPi"

# Clone AlpacaPi repository
on_chroot << EOF
cd /home/alpacapi
if [ -d "AlpacaPi" ]; then
    rm -rf AlpacaPi
fi
git clone https://github.com/mconsidine/AlpacaPi.git
cd AlpacaPi
git checkout openastro-alpaca
EOF

# Install additional Python packages
on_chroot << EOF
pip3 install --upgrade pip
pip3 install requests flask sqlalchemy psutil pillow matplotlib scipy astropy pyephem astroplan photutils ccdproc astroscrappy reproject regions ginga
EOF

# Build AlpacaPi
on_chroot << EOF
cd /home/alpacapi/AlpacaPi
mkdir -p build
cd build
cmake ..
make -j$(nproc)
make install
EOF

# Set up AlpacaPi configuration
on_chroot << EOF
mkdir -p /home/alpacapi/.config/alpacapi
mkdir -p /home/alpacapi/AlpacaPi/logs
chown -R alpacapi:alpacapi /home/alpacapi/.config/alpacapi
chown -R alpacapi:alpacapi /home/alpacapi/AlpacaPi
EOF

# Create AlpacaPi configuration file
on_chroot << EOF
cat > /home/alpacapi/.config/alpacapi/alpacapi.conf << 'CONF_EOF'
[General]
ServerPort=8000
ServerHost=0.0.0.0
LogLevel=INFO
LogFile=/home/alpacapi/AlpacaPi/logs/alpacapi.log

[Camera]
DefaultDriver=ZWO
AutoDetect=true

[Focuser]
DefaultDriver=ZWO
AutoDetect=true

[FilterWheel]
DefaultDriver=ZWO
AutoDetect=true
CONF_EOF
chown alpacapi:alpacapi /home/alpacapi/.config/alpacapi/alpacapi.conf
EOF

# Download and install camera SDKs
on_chroot << EOF
cd /home/alpacapi
mkdir -p camera-sdks
cd camera-sdks

# Download ZWO ASI SDK
if [ ! -f "ASI_linux_mac_SDK_V1.16.3.tar.bz2" ]; then
    echo "Downloading ZWO ASI SDK..."
    wget https://astronomy-imaging-camera.com/software/ASI_linux_mac_SDK_V1.16.3.tar.bz2
    tar -xjf ASI_linux_mac_SDK_V1.16.3.tar.bz2
fi

# Download ZWO EFW SDK
if [ ! -f "EFW_linux_mac_SDK_V1.5.0615.tar.bz2" ]; then
    echo "Downloading ZWO EFW SDK..."
    wget https://astronomy-imaging-camera.com/software/EFW_linux_mac_SDK_V1.5.0615.tar.bz2
    tar -xjf EFW_linux_mac_SDK_V1.5.0615.tar.bz2
fi

# Download QHY SDK
if [ ! -d "QHY" ]; then
    echo "Downloading QHY SDK..."
    mkdir -p QHY
    cd QHY
    # Download appropriate version based on architecture
    if [ "$(uname -m)" = "aarch64" ]; then
        wget https://www.qhyccd.com/file/repository/publish/SDK/25.09.29/sdk_Arm64_25.09.29.tgz
        tar -xzf sdk_Arm64_25.09.29.tgz
        mv sdk*/* .
    elif [ "$(uname -m)" = "armv7l" ]; then
        wget https://www.qhyccd.com/file/repository/publish/SDK/25.09.29/sdk_arm32_25.09.29.tgz
        tar -xzf sdk_arm32_25.09.29.tgz
        mv sdk*/* .
    else
        wget https://www.qhyccd.com/file/repository/publish/SDK/25.09.29/sdk_linux64_25.09.29.tgz
        tar -xzf sdk_linux64_25.09.29.tgz
        mv sdk*/* .
    fi
    cd ..
fi

# Download ATIK SDK
if [ ! -f "AtikCamerasSDK_2025_11_11_Master_2111.zip" ]; then
    echo "Downloading ATIK SDK..."
    wget https://downloads.atik-cameras.com/AtikCamerasSDK_2025_11_11_Master_2111.zip
    unzip AtikCamerasSDK_2025_11_11_Master_2111.zip
fi

# Download Touptek SDK
if [ ! -f "toupcamsdk.zip" ]; then
    echo "Downloading Touptek SDK..."
    curl -fsSL https://www.touptekphotonics.com/downloads/software/download.php?soft=toupcamsdk -o toupcamsdk.zip
    unzip toupcamsdk.zip
fi

chown -R alpacapi:alpacapi /home/alpacapi/camera-sdks
EOF

# Install udev rules
on_chroot << EOF
# Install ZWO ASI rules
if [ -f /home/alpacapi/camera-sdks/ASI_linux_mac_SDK_V1.16.3/lib/asi.rules ]; then
    cp /home/alpacapi/camera-sdks/ASI_linux_mac_SDK_V1.16.3/lib/asi.rules /lib/udev/rules.d/
    echo "Installed ZWO ASI udev rules"
fi

# Install ZWO EFW rules
if [ -f /home/alpacapi/camera-sdks/EFW_linux_mac_SDK_V1.5.0615/lib/efw.rules ]; then
    cp /home/alpacapi/camera-sdks/EFW_linux_mac_SDK_V1.5.0615/lib/efw.rules /lib/udev/rules.d/
    echo "Installed ZWO EFW udev rules"
fi

# Install ATIK rules
if [ -f /home/alpacapi/camera-sdks/AtikCamerasSDK/99-atik.rules ]; then
    cp /home/alpacapi/camera-sdks/AtikCamerasSDK/99-atik.rules /lib/udev/rules.d/
    echo "Installed ATIK udev rules"
fi

# Install Touptek rules
if [ -f /home/alpacapi/camera-sdks/toupcamsdk/linux/udev/99-toupcam.rules ]; then
    cp /home/alpacapi/camera-sdks/toupcamsdk/linux/udev/99-toupcam.rules /lib/udev/rules.d/
    echo "Installed Touptek udev rules"
fi

# Install QHY rules
if [ -f /home/alpacapi/camera-sdks/QHY/etc/udev/rules.d/85-qhyccd.rules ]; then
    cp /home/alpacapi/camera-sdks/QHY/etc/udev/rules.d/85-qhyccd.rules /lib/udev/rules.d/
    echo "Installed QHY udev rules"
fi

# Reload udev rules
udevadm control --reload-rules
udevadm trigger
EOF

# System tweaks
on_chroot << EOF
# Set hostname
echo "alpacapi" > /etc/hostname

# Update hosts file
echo "127.0.0.1 alpacapi" >> /etc/hosts

# Configure timezone (set to UTC for astronomy)
timedatectl set-timezone UTC

# Disable swap to prevent SD card wear
dphys-swapfile swapoff
systemctl disable dphys-swapfile

# Configure memory split for GPU (minimal for headless operation)
echo "gpu_mem=16" >> /boot/config.txt

# Enable I2C and SPI for hardware interfaces
echo "dtparam=i2c_arm=on" >> /boot/config.txt
echo "dtparam=spi=on" >> /boot/config.txt

# Configure for astronomy timing
echo "rtc-ds3231" >> /boot/config.txt

# Set up log rotation for AlpacaPi
cat > /etc/logrotate.d/alpacapi << 'LOGROTATE_EOF'
/home/alpacapi/AlpacaPi/logs/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 alpacapi alpacapi
}
LOGROTATE_EOF
EOF

# WiFi setup
on_chroot << EOF
# Configure hostapd for access point
cat > /etc/hostapd/hostapd.conf << 'HOSTAPD_EOF'
interface=wlan0
driver=nl80211
ssid=alpacapi
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=alpacapi
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
HOSTAPD_EOF

# Configure dnsmasq for DHCP
cat > /etc/dnsmasq.conf << 'DNSMASQ_EOF'
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
DNSMASQ_EOF

# Configure static IP for wlan0
cat > /etc/dhcpcd.conf << 'DHCPCD_EOF'
interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
DHCPCD_EOF

# Enable services
systemctl enable hostapd
systemctl enable dnsmasq
EOF
