# AlpacaPi

**Professional astronomy control software using the Alpaca protocol on Raspberry Pi 4 and Raspberry Pi 5**

[![License](https://img.shields.io/badge/License-Custom-blue.svg)](LICENSE.md)
[![Platform](https://img.shields.io/badge/Platform-Raspberry%20Pi-red.svg)](https://www.raspberrypi.org/)
[![Protocol](https://img.shields.io/badge/Protocol-Alpaca%20%2F%20ASCOM-green.svg)](https://ascom-standards.org/)
[![Build System](https://img.shields.io/badge/Build%20System-Node.js%20%2B%20Ubuntu%2024.04-orange.svg)](https://nodejs.org/)

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

#### **Complete Prerequisites Installation**

Before building AlpacaPi, you need to install several tools. Here's a complete installation guide:

**1. Update your system:**
```bash
sudo apt update && sudo apt upgrade -y
```

**2. Install essential build tools:**
```bash
sudo apt install -y \
    build-essential \
    cmake \
    pkg-config \
    git \
    curl \
    wget \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release
```

**3. Install Git (if not already installed):**
```bash
sudo apt install -y git
```

**4. Install Node.js 18+ and npm:**
```bash
# Add NodeSource repository for Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# Install Node.js and npm
sudo apt install -y nodejs

# Verify installation
node --version  # Should show v18.x.x or higher
npm --version   # Should show 8.x.x or higher
```

**5. Install Docker:**
```bash
# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add your user to the docker group
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
docker --version
```

**6. Install additional dependencies for pi-gen:**
```bash
sudo apt install -y \
    quilt \
    zerofree \
    libcap2-bin \
    xxd \
    file \
    kmod \
    bc \
    pigz \
    debootstrap \
    qemu-user-static
```

**7. Verify all installations:**
```bash
# Check all tools are installed
git --version
node --version
npm --version
docker --version
cmake --version
```

**8. Log out and log back in** (or restart) to ensure Docker group permissions take effect.

#### **Troubleshooting Prerequisites Installation**

**Common Issues and Solutions:**

**Git not found:**
```bash
sudo apt install -y git
```

**Node.js version too old:**
```bash
# Remove old version
sudo apt remove nodejs npm
# Install new version
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

**Docker permission denied:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and log back in, or run:
newgrp docker
```

**Docker not running:**
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

**Missing build tools:**
```bash
sudo apt install -y build-essential cmake pkg-config
```

**Pi-gen build fails:**
```bash
# Install missing dependencies
sudo apt install -y quilt zerofree libcap2-bin xxd file kmod bc pigz
```

#### **Alternative: One-Command Installation**

If you prefer to install everything at once:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install all prerequisites
sudo apt install -y \
    build-essential cmake pkg-config git curl wget unzip \
    software-properties-common apt-transport-https ca-certificates \
    gnupg lsb-release quilt zerofree libcap2-bin xxd file kmod \
    bc pigz debootstrap qemu-user-static

# Install Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && \
sudo apt install -y nodejs

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt update && \
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin && \
sudo usermod -aG docker $USER && \
sudo systemctl start docker && \
sudo systemctl enable docker

# Verify installations
echo "Git: $(git --version)"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "Docker: $(docker --version)"
echo "CMake: $(cmake --version)"
```

#### **Installing Node.js on Ubuntu 24.04 LTS (Alternative Methods)**

1. **Using NodeSource Repository (Recommended)**:
   ```bash
   # Update package index
   sudo apt update
   
   # Install curl if not already installed
   sudo apt install -y curl
   
   # Add NodeSource repository for Node.js 18.x
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   
   # Install Node.js
   sudo apt install -y nodejs
   ```

2. **Using Snap (Alternative)**:
   ```bash
   sudo snap install node --classic
   ```

3. **Using Node Version Manager (nvm)**:
   ```bash
   # Install nvm
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
   
   # Restart terminal or source profile
   source ~/.bashrc
   
   # Install latest LTS Node.js
   nvm install --lts
   nvm use --lts
   ```

#### **Installing Docker on Ubuntu 24.04 LTS**

```bash
# Update package index
sudo apt update

# Install required packages
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add your user to the docker group
sudo usermod -aG docker $USER

# Log out and log back in for group changes to take effect
```

#### **Raspberry Pi 4 and Raspberry Pi 5 (Target Hardware Only)**

**Important**: Node.js is NOT needed on the Raspberry Pi itself. The build system runs on your Ubuntu development machine and creates custom Raspberry Pi OS images that can be flashed to SD cards.

#### **Verify Installation**

```bash
# Check Node.js version (should be 18+)
node --version

# Check npm version (should be 8+)
npm --version

# Check Docker installation
docker --version

# Verify Docker is running
docker info
```

### **Installation**

```bash
# Clone the repository
git clone https://github.com/open-astro/AlpacaPi.git
cd AlpacaPi

# Install dependencies
npm install

# Setup development environment
npm run setup

# Build AlpacaPi
npm run build
```

---

## 📋 **Available Scripts**

### **Build Scripts**
```bash
npm run build                    # Default build
npm run build:debug             # Debug build
npm run build:release           # Release build
npm run build:pi                # Raspberry Pi build (cross-compile)
npm run build:pi-gen            # Create custom Raspberry Pi OS image
```

### **Development Scripts**
```bash
npm run setup                   # Setup development environment
npm run test                    # Run tests
npm run clean                   # Basic cleanup (with confirmation)
npm run clean:artifacts         # Clean build artifacts only
npm run clean:all               # Clean everything except Docker
npm run clean:pi-gen            # Clean pi-gen and Docker (recommended for pi-gen builds)
npm run clean:full              # Complete cleanup (everything)
```

### **Docker Scripts**
```bash
npm run docker:build            # Docker build
npm run docker:pi-gen           # Build RPi OS image with Docker
```

---

## ⚙️ **Build Options**

### **Target Platforms**
- **Linux (x86_64)**: Native Ubuntu 24.04 LTS builds
- **Raspberry Pi 4**: ARM cross-compilation and custom OS images
- **Raspberry Pi 5**: ARM cross-compilation and custom OS images

### **Build Types**
- **Debug**: Development builds with debugging symbols
- **Release**: Optimized production builds
- **Minimal**: Server-only builds (no GUI components)
- **Full**: Complete builds with all drivers

### **Docker Options**
- **Cross-platform builds**: Consistent builds across different systems
- **Pi-gen integration**: Custom Raspberry Pi OS image creation
- **Dependency management**: Isolated build environments

### **Pi-Gen Options**
- **Custom OS images**: Pre-configured Raspberry Pi OS with AlpacaPi
- **Driver selection**: Choose which drivers to include
- **Auto-start**: Configure AlpacaPi to start automatically
- **User management**: Pre-configured system users and permissions

---

## 💻 **Development Workflow**

### **Complete Workflow: Ubuntu → Raspberry Pi 4/5**

This workflow shows how to develop on Ubuntu 24.04 LTS and deploy to Raspberry Pi 4 or Raspberry Pi 5.

### **1. Initial Setup (on your Ubuntu development machine)**

```bash
# Clone and setup
git clone https://github.com/open-astro/AlpacaPi.git
cd AlpacaPi
npm install
npm run setup

# Verify everything is working
npm run test
```

### **2. Development**

```bash
# Make changes to source code
# Test locally
npm run build:debug
npm run test

# Clean up when needed
npm run clean:artifacts
```

### **3. Testing**

```bash
# Run all tests
npm run test

# Build for Raspberry Pi (cross-compile)
npm run build:pi

# Test specific components
npm run test -- --grep "camera"
```

### **4. Building for Production**

```bash
# Create custom Raspberry Pi OS image
npm run build:pi-gen

# This creates a flashable .img file in pi-gen/export-image/work/export-image/
```

### **5. Deploying to Raspberry Pi 4 or Raspberry Pi 5**

1. **Flash the image**:
   - Use Raspberry Pi Imager to flash the generated `.img` file to an SD card
   - Insert SD card into your Raspberry Pi 4 or Raspberry Pi 5

2. **Boot and configure**:
   - Power on the Raspberry Pi
   - AlpacaPi will start automatically
   - Access via web interface at `http://raspberry-pi-ip:8000`

---

## 🐳 **Docker Integration**

### **Docker Builds**

The build system uses Docker for consistent, reproducible builds:

```bash
# Build using Docker
npm run docker:build

# Build Raspberry Pi OS image using Docker
npm run docker:pi-gen
```

### **Docker Images**

- **AlpacaPi Builder**: Cross-platform build environment
- **Raspberry Pi OS image builder for RPi 4 and RPi 5**: Custom pi-gen integration

---

## 💾 **Raspberry Pi Deployment**

### **Complete Deployment Workflow**

1. **Development** (Ubuntu 24.04 LTS):
   ```bash
   npm run build:pi-gen
   ```

2. **Image Creation**:
   - Creates custom Raspberry Pi OS image with AlpacaPi pre-installed
   - Includes all dependencies and drivers
   - Configures system to start AlpacaPi automatically

3. **Deployment**:
   - Flash image to SD card using Raspberry Pi Imager
   - Insert SD card into Raspberry Pi 4 or Raspberry Pi 5
   - Power on and connect to network

4. **Access**:
   - Web interface: `http://raspberry-pi-ip:8000`
   - AlpacaPi API: `http://raspberry-pi-ip:8000/api/v1/`

### **Image Variants**

- **AlpacaPi Lite**: Minimal server-only image (~500MB)
- **AlpacaPi Standard**: Common astronomy drivers (~800MB)
- **AlpacaPi Full**: All available drivers (~1.2GB)

---

## 📋 **Supported Devices**

### **📷 Cameras**
- **ZWO**: ASI series (ASI120, ASI1600, ASI2600, etc.)
- **ATIK**: 314L+, 383L+, 460EX, etc.
- **QHY**: QHY5L-II, QHY8L, QHY163M, etc.
- **QSI**: 600 series, 700 series
- **Touptek**: ATR3CMOS, IMX178, etc.
- **FLIR**: Chameleon3, Blackfly S
- **Sony**: IMX-based cameras
- **Player One**: Apollo series

### **🔭 Telescope Mounts**
- **LX200**: Meade LX200, LX400 series
- **SkyWatcher**: EQ6, AZ-EQ6, HEQ5, etc.
- **Custom**: Support for custom mount protocols

### **⚙️ Accessories**
- **Focusers**: MoonLite, ZWO EAF, Optec, etc.
- **Filter Wheels**: ZWO EFW, ATIK EFW2, etc.
- **Rotators**: ZWO EAF, Optec Pyxis, etc.
- **Domes**: AstroHaven, Pulsar, etc.
- **Switches**: Generic relay control

---

## 🧩 **Project Structure**

```
AlpacaPi/
├── src/                    # Source code
│   ├── core/              # Core AlpacaPi functionality
│   ├── drivers/           # Device drivers
│   └── util/              # Utility functions
├── include/               # Header files
├── examples/              # Example applications
├── docs/                  # Documentation
├── pi-gen/                # Custom Raspberry Pi OS image builder
├── scripts/               # Build and utility scripts
├── package.json           # Node.js configuration
├── build.js               # Main build script
├── clean.js               # Cleanup script
└── setup.js               # Setup script
```

---

## 🔧 **Advanced Usage**

### **Custom Build Configuration**

```bash
# Build with specific drivers
npm run build:pi-gen -- --drivers="zwo,atik,qhy"

# Build minimal image
npm run build:pi-gen -- --minimal

# Build with custom configuration
npm run build:pi-gen -- --config=my-config.json
```

### **Platform Building**

```bash
# Cross-compile for Raspberry Pi
npm run build:pi

# Build for specific architecture
npm run build:pi -- --arch=arm64
```

### **Pi-Gen Customization**

```bash
# Custom pi-gen configuration
cd pi-gen
cp config_alpacapi config
# Edit config file
./build-alpacapi.sh
```

---

## 🛡️ **Prerequisites**

### **Required**
- **Ubuntu 24.04 LTS** (tested and verified development platform)
- **Node.js 18+** and **npm 8+**
- **Docker** (for pi-gen builds)
- **Git** (for cloning repository)

### **Optional**
- **Raspberry Pi 4 or Raspberry Pi 5** (target hardware)
- **SD card** (for flashing custom images)
- **Raspberry Pi Imager** (for flashing images)

---

## ❓ **Troubleshooting**

### **Common Issues**

#### **Node.js Installation Issues**
```bash
# Check Node.js version
node --version

# If version is too old, reinstall
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

#### **Permission Issues (Ubuntu)**
```bash
# Fix npm permissions
sudo chown -R $(whoami) ~/.npm

# Fix Docker permissions
sudo usermod -aG docker $USER
# Log out and log back in
```

#### **Docker Not Running**
```bash
# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Check Docker status
sudo systemctl status docker
```

#### **Build Failures**
```bash
# Clean everything and try again
npm run clean:full
npm install
npm run build

# Check for specific errors
npm run build -- --verbose
```

#### **Test Failures**
```bash
# Run tests with verbose output
npm run test -- --verbose

# Run specific tests
npm run test -- --grep "camera"
```

### **Getting Help**

- **GitHub Issues**: [Report bugs and request features](https://github.com/open-astro/AlpacaPi/issues)
- **Documentation**: Check the `docs/` directory for detailed guides
- **Community**: Join our community discussions

---

## 📈 **ASCOM Conformance**

AlpacaPi implements the ASCOM Alpaca protocol specification, providing compatibility with:

- **NINA**: Nighttime Imaging 'N' Astronomy
- **SharpCap**: Planetary imaging and EAA
- **PHD2**: Guiding software
- **SGP**: Sequence Generator Pro
- **MaxIm DL**: Professional imaging software
- **TheSkyX**: Professional planetarium software

### **Supported ASCOM Device Types**
- **Telescope**: Mount control and pointing
- **Camera**: Image acquisition and control
- **FilterWheel**: Filter selection
- **Focuser**: Focus control
- **Rotator**: Camera rotation
- **Dome**: Observatory dome control
- **Switch**: Generic relay control

---

## 👥 **Contributing**

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### **Development Priorities**
1. **Driver Development**: New camera and accessory drivers
2. **Protocol Support**: Additional ASCOM device types
3. **Testing**: Automated testing and validation
4. **Documentation**: User guides and API documentation
5. **Performance**: Optimization and reliability improvements

---

## 📄 **License**

This project is licensed under a custom license. See [LICENSE.md](LICENSE.md) for details.

### **Usage Terms**
- **Commercial Use**: Allowed with attribution
- **Modification**: Allowed
- **Distribution**: Allowed
- **Private Use**: Allowed

---

## ❤️ **Acknowledgments**

- **ASCOM Standards**: For the Alpaca protocol specification
- **Raspberry Pi Foundation**: For the amazing hardware platform
- **Open Source Community**: For the tools and libraries that make this possible
- **Astronomy Community**: For feedback and testing

---

## 🎧 **Support**

- **Documentation**: Check the `docs/` directory
- **GitHub Issues**: [Report bugs and request features](https://github.com/open-astro/AlpacaPi/issues)
- **Community**: Join our community discussions
- **Email**: Contact the maintainers

---

## 🎁 **Donations**

If you find AlpacaPi useful, please consider supporting the project:

- **GitHub Sponsors**: Support ongoing development
- **PayPal**: One-time donations
- **Hardware**: Donate Raspberry Pi hardware for testing

---

## ⚡ **Quick Reference**

### **Most Common Commands**

```bash
# Setup
npm install
npm run setup

# Development
npm run build:debug
npm run test

# Production
npm run build:pi-gen

# Cleanup
npm run clean:pi-gen
```

### **Advanced Commands**

```bash
# Custom builds
npm run build:pi-gen -- --drivers="zwo,atik"
npm run build:pi-gen -- --minimal

# Docker builds
npm run docker:pi-gen

# Complete cleanup
npm run clean:full
```

### **Cleanup Commands Reference**

| Command | Build Artifacts | Docker | Pi-gen | Logs | Temp Files | Node Modules |
|---------|----------------|--------|--------|------|------------|--------------|
| `clean` | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| `clean:artifacts` | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| `clean:all` | ✅ | ❌ | ❌ | ✅ | ✅ | ❌ |
| `clean:pi-gen` | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ |
| `clean:full` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

---

**Happy Observing! 🌟**