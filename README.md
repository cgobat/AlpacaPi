# AlpacaPi

**Professional astronomy control software using the Alpaca protocol on Raspberry Pi 4 and Raspberry Pi 5**

[![License](https://img.shields.io/badge/License-Custom-blue.svg)](LICENSE.md)
[![Platform](https://img.shields.io/badge/Platform-Raspberry%20Pi-red.svg)](https://www.raspberrypi.org/)
[![Protocol](https://img.shields.io/badge/Protocol-Alpaca%20%2F%20ASCOM-green.svg)](https://ascom-standards.org/)
[![Build System](https://img.shields.io/badge/Build%20System-Shell%20Scripts%20%2B%20Ubuntu%2024.04-orange.svg)](https://ubuntu.com/)

---

## 🎯 **What is AlpacaPi?**

AlpacaPi is a comprehensive astronomy control system that transforms your Raspberry Pi 4 or Raspberry Pi 5 into a powerful observatory controller. It provides ASCOM Alpaca protocol compatibility, allowing seamless integration with popular astronomy software like **NINA**, **SharpCap**, **PHD2**, and **SGP**.

### ⭐ **Key Features**

- **🌐 Alpaca Protocol**: Full ASCOM Alpaca compatibility for modern astronomy software
- **📷 Camera Support**: ZWO, ATIK, QHY, QSI, Touptek, FLIR, Sony, and more
- **🔭 Telescope Control**: LX200, SkyWatcher, and custom mount protocols
- **⚙️ Accessory Control**: Focusers, filter wheels, domes, switches, and rotators
- **🚀 Ready-to-Deploy**: Custom Raspberry Pi OS images with pre-installed AlpacaPi for RPi 4 and RPi 5
- **🧩 Modular Design**: Install only the drivers you need
- **📱 Remote Control**: Web-based interface and API access

---

## 🚀 **Quick Start**

### **Prerequisites: Ubuntu 24.04 LTS (Tested)**

AlpacaPi is designed to build custom Raspberry Pi OS images for Raspberry Pi 4 and Raspberry Pi 5 using Ubuntu 24.04 LTS as the development platform. We have tested and verified compatibility with this setup.

### **One-Command Installation**

Install all prerequisites with a single command:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install all prerequisites
sudo apt install -y \
    build-essential cmake pkg-config git curl wget unzip \
    software-properties-common apt-transport-https ca-certificates \
    gnupg lsb-release quilt zerofree libcap2-bin xxd file kmod \
    bc pigz debootstrap qemu-user-static

# Install Docker (choose one method)

# Method 1: Snap installation (recommended for stability)
sudo snap install docker && \
sudo usermod -aG snap_docker $USER && \
sudo snap start docker

# Method 2: Official Docker repository (alternative)
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
# sudo apt update && \
# sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin && \
# sudo usermod -aG docker $USER && \
# sudo systemctl start docker && \
# sudo systemctl enable docker

# Verify installations
echo "Git: $(git --version)"
echo "Docker: $(docker --version)"
echo "CMake: $(cmake --version)"
```

### **Build Custom Raspberry Pi OS Image**

Create a custom Raspberry Pi OS image with AlpacaPi pre-installed:

```bash
# Clone the repository
git clone https://github.com/open-astro/AlpacaPi.git
cd AlpacaPi

# OPTIONAL: Optimize build environment for maximum performance
cd alpacapi-builder && ./optimize-build.sh

# Build for Raspberry Pi 4/5 (ARM64) - Uses all CPU cores
cd alpacapi-builder && ./build_arm64.sh

# Or build for older Raspberry Pi (ARMHF) - Uses all CPU cores
cd alpacapi-builder && ./build_armhf.sh

# Clean build artifacts
rm -rf alpacapi-builder/pi-gen-* && rm -f alpacapi-builder/*-alpacapi-*.zip
```

**Performance Notes:**
- **Build time**: 30-60 minutes (depending on CPU cores)
- **CPU usage**: Automatically uses all available cores
- **Memory**: 2GB+ RAM recommended for optimal performance
- **Storage**: Fast SSD recommended for best build times

**Important:** After running this command, log out and log back in (or restart) to ensure Docker group permissions take effect.


---

## 📋 **Available Commands**

### **Build Commands**

| Command | Description |
|---------|-------------|
| `cd alpacapi-builder && ./optimize-build.sh` | **OPTIONAL**: Optimize build environment for maximum performance |
| `cd alpacapi-builder && ./build_arm64.sh` | Build custom Raspberry Pi OS image for RPi 4/5 (ARM64) - Uses all CPU cores |
| `cd alpacapi-builder && ./build_armhf.sh` | Build custom Raspberry Pi OS image for older RPi (ARMHF) - Uses all CPU cores |

### **Performance Optimization**

| Feature | Description |
|---------|-------------|
| **Multi-core compilation** | Automatically uses all available CPU cores |
| **ccache** | 2GB cache for faster C++ compilation |
| **Parallel downloads** | apt and pip configured for parallel package downloads |
| **Docker BuildKit** | Parallel Docker builds for faster image creation |
| **Build caching** | Intelligent caching for faster rebuilds |

### **Cleanup Commands**

| Command | Description |
|---------|-------------|
| `rm -rf alpacapi-builder/pi-gen-*` | Remove pi-gen work directories |
| `rm -f alpacapi-builder/*-alpacapi-*.zip` | Remove generated image files |

---

## ⚙️ **Build Options**

### **Target Platforms**

- **Linux (x86_64)**: Native build on Ubuntu 24.04 LTS
- **Raspberry Pi 4**: ARM64 cross-compilation
- **Raspberry Pi 5**: ARM64 cross-compilation

### **Build Types**

- **Release**: Optimized production build
- **Debug**: Development build with debug symbols

---

## 🚀 **Build Performance & Optimization**

### **Automatic Multi-Core Processing**

AlpacaPi's build system automatically detects and utilizes all available CPU cores:

- **CMake builds**: Uses `make -j$(nproc)` for maximum parallel compilation
- **Python packages**: Parallel pip installation with optimized settings
- **System packages**: apt configured for parallel downloads
- **Docker builds**: BuildKit enabled for parallel container operations

### **Performance Optimizations**

| Optimization | Benefit | Description |
|-------------|---------|-------------|
| **ccache** | 50-70% faster rebuilds | 2GB cache for C++ compilation |
| **Parallel downloads** | 3-5x faster package installs | apt and pip configured for parallel operations |
| **Docker BuildKit** | 30-50% faster builds | Parallel Docker layer builds |
| **Memory optimization** | Better resource utilization | Optimized swap and memory settings |
| **Build caching** | Faster incremental builds | Intelligent dependency tracking |

### **System-Specific Optimization**

#### **High-Core Systems (16+ cores)**
For systems like AMD Threadripper, Intel Xeon, or high-end Ryzen:

```bash
# Run optimization script for maximum performance
cd alpacapi-builder && ./optimize-build.sh

# This automatically configures:
# - 2x CPU cores for parallel jobs (I/O bound tasks)
# - 8GB ccache for faster C++ compilation
# - Docker daemon optimization for concurrent operations
# - System limits tuning for high-core count
```

#### **Standard Multi-Core Systems (4-16 cores)**
For typical desktop and server systems:

```bash
# Build with automatic optimization
cd alpacapi-builder && ./build_arm64.sh

# The build system automatically:
# - Uses all available CPU cores
# - Configures 2GB ccache
# - Enables parallel downloads
# - Optimizes Docker for your system
```

#### **Low-Core Systems (2-4 cores)**
For older systems or VMs:

```bash
# Build with conservative settings
cd alpacapi-builder && ./build_arm64.sh

# System automatically adjusts:
# - Uses all cores but limits parallel jobs
# - Smaller ccache (1GB) to save memory
# - Conservative Docker settings
# - Optimized for limited resources
```

### **Docker Installation Optimization**

#### **Recommended: Snap Installation (Most Reliable)**
```bash
# Install Docker via snap (recommended for stability)
sudo snap install docker

# Add user to docker group
sudo usermod -aG snap_docker $USER

# Start Docker service
sudo snap start docker
```

#### **Alternative: Official Docker Repository**
```bash
# Install Docker from official repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker
```

### **System Requirements for Optimal Performance**

| System Type | CPU | RAM | Storage | Expected Build Time |
|-------------|-----|-----|---------|-------------------|
| **High-End** | 16+ cores | 16GB+ | NVMe SSD | 5-15 minutes |
| **Standard** | 4-16 cores | 8-16GB | SSD | 15-45 minutes |
| **Budget** | 2-4 cores | 4-8GB | HDD/SSD | 45-90 minutes |
| **VM/Cloud** | 2-8 cores | 4-16GB | Cloud storage | 30-120 minutes |

### **Build Time Estimates**

| System Configuration | Build Time (ARM64) | Build Time (ARMHF) | Notes |
|---------------------|-------------------|-------------------|-------|
| **AMD Threadripper 7960X** (48 cores, 125GB RAM) | 5-10 minutes | 4-8 minutes | With optimization script |
| **Intel i9-13900K** (24 cores, 32GB RAM) | 8-15 minutes | 6-12 minutes | With optimization script |
| **AMD Ryzen 7 5800X** (16 cores, 32GB RAM) | 12-20 minutes | 10-18 minutes | Standard optimization |
| **Intel i5-12400** (12 cores, 16GB RAM) | 20-35 minutes | 18-30 minutes | Standard optimization |
| **AMD Ryzen 5 5600X** (12 cores, 16GB RAM) | 25-40 minutes | 20-35 minutes | Standard optimization |
| **Intel i3-12100** (8 cores, 8GB RAM) | 35-60 minutes | 30-50 minutes | Conservative settings |
| **Raspberry Pi 4** (4 cores, 8GB RAM) | 60-120 minutes | 50-100 minutes | Native build only |

---

## 💻 **Development Workflow**

### **Complete Workflow: Ubuntu → Raspberry Pi 4/5**

1. **Setup Development Environment** (Ubuntu 24.04 LTS):
   ```bash
   # Install prerequisites (one command)
   sudo apt update && sudo apt upgrade -y && \
   sudo apt install -y build-essential cmake pkg-config git curl wget unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release quilt zerofree libcap2-bin xxd file kmod bc pigz debootstrap qemu-user-static && \
   sudo snap install docker && \
   sudo usermod -aG snap_docker $USER && \
   sudo snap start docker
   ```

2. **Clone and Setup**:
   ```bash
   git clone https://github.com/open-astro/AlpacaPi.git
   cd AlpacaPi
   ```

3. **Create Custom RPi OS Image**:
   ```bash
   # OPTIONAL: Optimize build environment for maximum performance
   cd alpacapi-builder && ./optimize-build.sh
   
   # Generate flashable image with AlpacaPi pre-installed (uses all CPU cores)
   cd alpacapi-builder && ./build_arm64.sh
   ```

4. **Deploy to Raspberry Pi**:
   ```bash
   # Flash the generated image to SD card
   # Image will be in alpacapi-builder/*-alpacapi-arm64.zip
   ```

---

## 🐳 **Docker Integration**

### **Docker Builds**

AlpacaPi uses Docker for consistent cross-platform builds:

- **Base Image**: Ubuntu 24.04 LTS
- **Cross-compilation**: ARM64 for Raspberry Pi
- **Dependencies**: All build tools pre-installed
- **Isolation**: Clean build environment

### **Docker Commands**

```bash
# Optimize Docker for parallel builds (run once)
cd alpacapi-builder && ./optimize-build.sh

# Build custom Raspberry Pi OS image
cd alpacapi-builder && ./build_arm64.sh

# The build process automatically:
# - Uses Docker BuildKit for parallel builds
# - Utilizes all available CPU cores
# - Configures ccache for faster compilation
# - Downloads and builds pi-gen automatically
```

---

## 💾 **Raspberry Pi Deployment**

### **Complete Deployment Workflow**

1. **Build Custom Image**:
   ```bash
   # Optimize build environment (optional but recommended)
   cd alpacapi-builder && ./optimize-build.sh
   
   # Build custom Raspberry Pi OS image
   cd alpacapi-builder && ./build_arm64.sh
   ```

2. **Flash to SD Card**:
   ```bash
   # Find your SD card device
   lsblk
   
   # Flash the image (replace /dev/sdX with your device)
   sudo dd if=pi-gen/work/AlpacaPi/2024-XX-XX-AlpacaPi.img of=/dev/sdX bs=4M status=progress
   ```

3. **Boot Raspberry Pi**:
   - Insert SD card into Raspberry Pi 4 or 5
   - Power on and connect to network
   - AlpacaPi will start automatically

4. **Access AlpacaPi**:
   - Web interface: `http://raspberry-pi-ip:8000`
   - API endpoint: `http://raspberry-pi-ip:8000/api/v1`

---

## 📋 **Supported Devices**

### **📷 Cameras**

- **ZWO**: ASI series (ASI120, ASI1600, ASI2600, etc.)
- **ATIK**: ATIK 314L+, ATIK 383L+, etc.
- **QHY**: QHY5L-II, QHY8L, QHY163M, etc.
- **QSI**: QSI 660, QSI 690, etc.
- **Touptek**: ToupTek cameras
- **FLIR**: FLIR cameras
- **Sony**: Sony IMX sensors

### **🔭 Telescope Mounts**

- **LX200**: Meade LX200 series
- **SkyWatcher**: SynScan protocol
- **Custom**: Protocol extensions

### **⚙️ Accessories**

- **Focusers**: MoonLite, ZWO EAF, etc.
- **Filter Wheels**: ZWO EFW, ATIK EFW, etc.
- **Domes**: Custom dome controllers
- **Switches**: Relay control systems
- **Rotators**: Camera rotators

---

## 🧩 **Project Structure**

```
AlpacaPi/
├── src/                    # Source code
│   ├── core/              # Core AlpacaPi functionality
│   ├── net/               # Network layer
│   └── util/              # Utilities
├── drivers/               # Hardware drivers
├── include/               # Header files
├── examples/              # Example applications
├── docs/                  # Documentation
├── pi-gen/                # Raspberry Pi OS image builder
├── package.json           # Node.js configuration
├── build.js              # Build system
└── README.md             # This file
```

---

## 🔧 **Advanced Usage**

### **Custom Build Configuration**

```bash
# Build with specific options
npm run build -- --type=debug --platform=pi --verbose

# Clean build
npm run build -- --clean

# Build without Docker
npm run build -- --no-docker
```

### **Environment Variables**

```bash
# Set build type
export BUILD_TYPE=release

# Set target platform
export TARGET_PLATFORM=pi

# Enable verbose output
export VERBOSE=true
```

---

## 🛡️ **Prerequisites**

### **Required**

- **Ubuntu 24.04 LTS** (tested and verified)
- **Node.js 18+** and **npm 8+**
- **Docker** (for cross-compilation)
- **Git** (for cloning repository)
- **CMake** (for building C++ components)

### **Optional**

- **pi-gen dependencies** (for custom RPi OS images)
- **QEMU** (for ARM emulation)

---

## ❓ **Troubleshooting**

### **Common Issues**

**Build fails:**
```bash
# Check prerequisites
npm run build -- --verbose

# Clean and rebuild
npm run clean && npm run build
```

**Docker permission denied:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in
```

**Pi-gen build fails:**
```bash
# Install missing dependencies
sudo apt install -y quilt zerofree libcap2-bin xxd file kmod bc pigz
```

**Node.js version too old:**
```bash
# Update Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

---

## 📈 **ASCOM Conformance**

AlpacaPi implements the ASCOM Alpaca protocol specification, providing compatibility with:

- **NINA**: Nighttime Imaging 'N' Astronomy
- **SharpCap**: Planetary imaging software
- **PHD2**: Guiding software
- **SGP**: Sequence Generator Pro
- **MaxIm DL**: Professional imaging software
- **TheSkyX**: Professional planetarium software

---

## 👥 **Contributing**

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### **Development Setup**

1. Fork the repository
2. Clone your fork
3. Install dependencies: `npm install`
4. Make your changes
5. Test: `npm run build`
6. Submit a pull request

---

## 📄 **License**

This project is licensed under a custom license. See [LICENSE.md](LICENSE.md) for details.

---

## ❤️ **Acknowledgments**

- **ASCOM Standards**: For the Alpaca protocol specification
- **Raspberry Pi Foundation**: For the amazing hardware platform
- **Open Source Community**: For the tools and libraries that make this possible

---

## 🎧 **Support**

- **Documentation**: Check the `docs/` directory
- **Issues**: Report bugs on GitHub Issues
- **Discussions**: Join the community discussions
- **Email**: Contact the maintainers

---

## 🎁 **Donations**

If you find AlpacaPi useful, please consider supporting the project:

- **GitHub Sponsors**: Support ongoing development
- **PayPal**: One-time donations
- **Hardware**: Donate hardware for testing

---

## ⚡ **Quick Reference**

### **Most Common Commands**

```bash
# Install everything
sudo apt update && sudo apt upgrade -y && sudo apt install -y build-essential cmake pkg-config git curl wget unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release quilt zerofree libcap2-bin xxd file kmod bc pigz debootstrap qemu-user-static && sudo snap install docker && sudo usermod -aG snap_docker $USER && sudo snap start docker

# Clone and setup
git clone https://github.com/open-astro/AlpacaPi.git && cd AlpacaPi

# OPTIONAL: Optimize for high-core systems
cd alpacapi-builder && ./optimize-build.sh

# Build custom RPi OS image
cd alpacapi-builder && ./build_arm64.sh

# Clean everything
rm -rf alpacapi-builder/pi-gen-* && rm -f alpacapi-builder/*-alpacapi-*.zip
```
