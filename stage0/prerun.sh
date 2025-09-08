#!/bin/bash -e

if [ "$RELEASE" != "trixie" ]; then
        echo "WARNING: RELEASE does not match the intended option for this branch."
        echo "         Please check the relevant README.md section."
fi

if [ ! -d "${ROOTFS_DIR}" ]; then
        # Create the parent directory for the rootfs
        mkdir -p "$(dirname "${ROOTFS_DIR}")"
        bootstrap ${RELEASE} "${ROOTFS_DIR}" http://raspbian.raspberrypi.com/raspbian/
fi
