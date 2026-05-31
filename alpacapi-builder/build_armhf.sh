#!/bin/bash
set -Eeuo pipefail
. "$(dirname "$0")/common.sh"

work_dir="pi-gen-armhf"
src_repo="https://github.com/RPi-Distro/pi-gen.git"
used_commit="master"
arch="armhf"
build_alpacapi
