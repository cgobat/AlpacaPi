
# AlpacaPi Cross-Platform Builder
FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    unzip \
    pkg-config \
    libusb-1.0-0-dev \
    libudev-dev \
    libi2c-dev \
    libcfitsio-dev \
    libjpeg-dev \
    libpng-dev \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-pip \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install OpenCV (for camera drivers)
RUN apt-get update && apt-get install -y \
    libopencv-dev \
    libopencv-contrib-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy source code
COPY . /workspace/

# Create build directory
RUN mkdir -p build

# Set build script
COPY build-docker.sh /workspace/
RUN chmod +x /workspace/build-docker.sh

# Default command
CMD ["/workspace/build-docker.sh"]
