#!/bin/bash
set -e

export VIRTUAL_ENV="/opt/alpacapi/venv"
export PATH="${VIRTUAL_ENV}/bin:/home/alpacapi/AlpacaPi/build:/usr/local/bin:${PATH}"
export LD_LIBRARY_PATH="/home/alpacapi/AlpacaPi/build:${LD_LIBRARY_PATH:-}"

cd /home/alpacapi/AlpacaPi
exec /usr/local/bin/alpacapi
