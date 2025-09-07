#!/bin/bash
# AlpacaPi Custom Stage for pi-gen
# This stage installs and configures AlpacaPi on Raspberry Pi OS

set -e

# Source common functions
if [ -f "${STAGE_WORK_DIR}/export-image/prerun.sh" ]; then
    source "${STAGE_WORK_DIR}/export-image/prerun.sh"
fi

# AlpacaPi stage configuration
ALPACAPI_STAGE_DIR="${STAGE_WORK_DIR}/stage-alpacapi"
ALPACAPI_ROOTFS="${STAGE_WORK_DIR}/stage-alpacapi/rootfs"

# Create rootfs directory
mkdir -p "${ALPACAPI_ROOTFS}"

# Copy files from previous stage
if [ -d "${STAGE_WORK_DIR}/stage2/rootfs" ]; then
    cp -a "${STAGE_WORK_DIR}/stage2/rootfs"/* "${ALPACAPI_ROOTFS}/"
fi

# Set up chroot environment
mount -t proc proc "${ALPACAPI_ROOTFS}/proc"
mount -t sysfs sysfs "${ALPACAPI_ROOTFS}/sys"
mount -t devtmpfs devtmpfs "${ALPACAPI_ROOTFS}/dev"
mount -t tmpfs tmpfs "${ALPACAPI_ROOTFS}/dev/shm"
mount -t devpts devpts "${ALPACAPI_ROOTFS}/dev/pts"

# Run installation scripts
for script in "${ALPACAPI_STAGE_DIR}"/*.sh; do
    if [ -f "${script}" ] && [ "${script}" != "${ALPACAPI_STAGE_DIR}/00-run.sh" ]; then
        echo "Running $(basename "${script}")"
        chroot "${ALPACAPI_ROOTFS}" /bin/bash < "${script}"
    fi
done

# Clean up mounts
umount "${ALPACAPI_ROOTFS}/dev/pts" || true
umount "${ALPACAPI_ROOTFS}/dev/shm" || true
umount "${ALPACAPI_ROOTFS}/dev" || true
umount "${ALPACAPI_ROOTFS}/sys" || true
umount "${ALPACAPI_ROOTFS}/proc" || true

echo "AlpacaPi stage completed successfully"
