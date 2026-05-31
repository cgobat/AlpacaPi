#!/bin/bash -e

# Clone, build, and configure AlpacaPi inside the image rootfs.
# Keep Python packages isolated in a venv so Debian/Raspberry Pi OS PEP 668
# protections remain intact.

on_chroot << 'EOF_CHROOT'
set -e

ALPACAPI_USER="alpacapi"
ALPACAPI_HOME="/home/${ALPACAPI_USER}"
ALPACAPI_DIR="${ALPACAPI_HOME}/AlpacaPi"
ALPACAPI_VENV="/opt/alpacapi/venv"

cd "${ALPACAPI_HOME}"
rm -rf "${ALPACAPI_DIR}"
git clone https://github.com/mconsidine/AlpacaPi.git "${ALPACAPI_DIR}"
cd "${ALPACAPI_DIR}"
git checkout openastro-alpaca

python3 -m venv --system-site-packages "${ALPACAPI_VENV}"
"${ALPACAPI_VENV}/bin/python" -m pip install --upgrade --no-cache-dir pip setuptools wheel
"${ALPACAPI_VENV}/bin/python" -m pip install --upgrade --no-cache-dir ephem

CORES="$(nproc)"
echo "Building AlpacaPi using ${CORES} CPU cores"

if [ -f CMakeLists.txt ]; then
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
    cmake --build build --parallel "${CORES}"
    cmake --install build || true
elif [ -f Makefile ] || [ -f makefile ]; then
    make -j"${CORES}"
    make install || true
else
    echo "Error: AlpacaPi checkout does not contain CMakeLists.txt or Makefile." >&2
    exit 1
fi

ALPACAPI_BIN=""
for candidate in \
    /usr/local/bin/alpacapi \
    "${ALPACAPI_DIR}/build/alpacapi" \
    "${ALPACAPI_DIR}/alpacapi"; do
    if [ -x "${candidate}" ]; then
        ALPACAPI_BIN="${candidate}"
        break
    fi
done

if [ -z "${ALPACAPI_BIN}" ]; then
    ALPACAPI_BIN="$(find "${ALPACAPI_DIR}" -maxdepth 4 -type f -perm -111 -iname 'alpacapi*' | head -1)"
fi

if [ -z "${ALPACAPI_BIN}" ]; then
    echo "Error: AlpacaPi build completed, but no executable named alpacapi was found." >&2
    find "${ALPACAPI_DIR}" -maxdepth 4 -type f -perm -111 -print >&2
    exit 1
fi

ln -sf "${ALPACAPI_BIN}" /usr/local/bin/alpacapi

mkdir -p "${ALPACAPI_HOME}/.config/alpacapi" "${ALPACAPI_DIR}/logs"
cat > "${ALPACAPI_HOME}/.config/alpacapi/alpacapi.conf" << 'CONF_EOF'
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

mkdir -p /home/alpacapi/camera-sdks
chown -R "${ALPACAPI_USER}:${ALPACAPI_USER}" "${ALPACAPI_HOME}" /opt/alpacapi
EOF_CHROOT

on_chroot << 'EOF_CHROOT'
set -e

cd /home/alpacapi/camera-sdks

# Vendor SDK downloads are intentionally best-effort. A transient vendor outage
# should not make the base OS image unbuildable, and the AlpacaPi build above is
# already complete before these optional runtime SDK/rules assets are installed.

if [ ! -f "ASI_linux_mac_SDK_V1.16.3.tar.bz2" ]; then
    echo "Downloading ZWO ASI SDK..."
    wget -T 30 -t 3 https://astronomy-imaging-camera.com/software/ASI_linux_mac_SDK_V1.16.3.tar.bz2 && \
        tar -xjf ASI_linux_mac_SDK_V1.16.3.tar.bz2 || \
        echo "Warning: failed to install ZWO ASI SDK."
fi

if [ ! -f "EFW_linux_mac_SDK_V1.5.0615.tar.bz2" ]; then
    echo "Downloading ZWO EFW SDK..."
    wget -T 30 -t 3 https://astronomy-imaging-camera.com/software/EFW_linux_mac_SDK_V1.5.0615.tar.bz2 && \
        tar -xjf EFW_linux_mac_SDK_V1.5.0615.tar.bz2 || \
        echo "Warning: failed to install ZWO EFW SDK."
fi

if [ ! -d "QHY" ]; then
    echo "Downloading QHY SDK..."
    mkdir -p QHY
    (
        cd QHY
        case "$(uname -m)" in
            aarch64)
                sdk_url="https://www.qhyccd.com/file/repository/publish/SDK/25.09.29/sdk_Arm64_25.09.29.tgz"
                sdk_file="sdk_Arm64_25.09.29.tgz"
                ;;
            armv7l)
                sdk_url="https://www.qhyccd.com/file/repository/publish/SDK/25.09.29/sdk_arm32_25.09.29.tgz"
                sdk_file="sdk_arm32_25.09.29.tgz"
                ;;
            *)
                sdk_url="https://www.qhyccd.com/file/repository/publish/SDK/25.09.29/sdk_linux64_25.09.29.tgz"
                sdk_file="sdk_linux64_25.09.29.tgz"
                ;;
        esac
        wget -T 30 -t 3 "${sdk_url}" -O "${sdk_file}" && \
            tar -xzf "${sdk_file}" && \
            find . -mindepth 2 -maxdepth 2 -type f -exec mv -t . {} + || \
            echo "Warning: failed to install QHY SDK."
    )
fi

if [ ! -f "AtikCamerasSDK_2025_11_11_Master_2111.zip" ]; then
    echo "Downloading ATIK SDK..."
    wget -T 30 -t 3 https://downloads.atik-cameras.com/AtikCamerasSDK_2025_11_11_Master_2111.zip && \
        unzip -o AtikCamerasSDK_2025_11_11_Master_2111.zip || \
        echo "Warning: failed to install ATIK SDK."
fi

if [ ! -f "toupcamsdk.zip" ]; then
    echo "Downloading Touptek SDK..."
    curl -fsSL --connect-timeout 30 --retry 3 "https://www.touptekphotonics.com/downloads/software/download.php?soft=toupcamsdk" -o toupcamsdk.zip && \
        unzip -o toupcamsdk.zip || \
        echo "Warning: failed to install Touptek SDK."
fi

chown -R alpacapi:alpacapi /home/alpacapi/camera-sdks
EOF_CHROOT

on_chroot << 'EOF_CHROOT'
set -e

install_rule() {
    src="$1"
    if [ -f "${src}" ]; then
        install -m 0644 "${src}" /lib/udev/rules.d/
        echo "Installed udev rule: ${src}"
    fi
}

install_rule /home/alpacapi/camera-sdks/ASI_linux_mac_SDK_V1.16.3/lib/asi.rules
install_rule /home/alpacapi/camera-sdks/EFW_linux_mac_SDK_V1.5.0615/lib/efw.rules
install_rule /home/alpacapi/camera-sdks/AtikCamerasSDK/99-atik.rules
install_rule /home/alpacapi/camera-sdks/toupcamsdk/linux/udev/99-toupcam.rules
install_rule /home/alpacapi/camera-sdks/QHY/etc/udev/rules.d/85-qhyccd.rules

udevadm control --reload-rules || true
udevadm trigger || true
EOF_CHROOT

on_chroot << 'EOF_CHROOT'
set -e

hostnamectl set-hostname alpacapi || echo "alpacapi" > /etc/hostname
grep -q '^127.0.0.1 alpacapi$' /etc/hosts || echo "127.0.0.1 alpacapi" >> /etc/hosts
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
echo "UTC" > /etc/timezone

dphys-swapfile swapoff || true
systemctl disable dphys-swapfile || true

boot_config="/boot/firmware/config.txt"
if [ -e /boot/config.txt ] && [ ! -e "${boot_config}" ]; then
    boot_config="/boot/config.txt"
fi
mkdir -p "$(dirname "${boot_config}")"
touch "${boot_config}"
append_config() {
    line="$1"
    grep -qxF "${line}" "${boot_config}" || echo "${line}" >> "${boot_config}"
}
append_config "gpu_mem=16"
append_config "dtparam=i2c_arm=on"
append_config "dtparam=spi=on"
append_config "dtoverlay=i2c-rtc,ds3231"

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

cat > /etc/dnsmasq.conf << 'DNSMASQ_EOF'
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
DNSMASQ_EOF

cat > /etc/dhcpcd.conf << 'DHCPCD_EOF'
interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
DHCPCD_EOF

systemctl enable hostapd || true
systemctl enable dnsmasq || true
EOF_CHROOT
