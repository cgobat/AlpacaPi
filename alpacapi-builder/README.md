Generate AlpacaPi Raspberry PI Image
==============

Make sure you have installed required packages and docker as described in
[pi-gen README.md](https://github.com/RPi-Distro/pi-gen/blob/master/README.md).

## Quick Start

For maximum build performance, run the optimization script first:
```bash
./optimize-build.sh
```

Then build the image:
```bash
./build_arm64.sh
```
The created image is named <DATE>-alpacapi-arm64.zip

```bash
./build_armhf.sh
```
The created image is named <DATE>-alpacapi-armhf.zip

Images contain several customizations:
0. Filesystem is expanded.
1. User 'alpacapi' with password 'alpacapi' is created.
2. AlpacaPi is cloned from GitHub and built from source.
3. All camera SDKs are installed (ZWO, QHY, ATIK, Touptek, FLIR).
4. udev rules are installed for camera access.
5. AlpacaPi process started via systemd as user alpacapi.
6. WiFi access point with SSID 'alpacapi' and password 'alpacapi' is created.
7. SSH daemon is started.
8. Sudo commands as user 'alpacapi' without password.
9. All required libraries and dependencies are pre-installed.
