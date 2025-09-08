#!/bin/bash

# AlpacaPi startup script
# This script starts the AlpacaPi service

cd /home/alpacapi/AlpacaPi

# Set environment variables
export PATH="/home/alpacapi/AlpacaPi/build:$PATH"
export LD_LIBRARY_PATH="/home/alpacapi/AlpacaPi/build:$LD_LIBRARY_PATH"

# Start AlpacaPi
exec /home/alpacapi/AlpacaPi/build/alpacapi
