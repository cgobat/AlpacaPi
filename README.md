# AlpacaPi

**Professional astronomy control software using the Alpaca protocol on Raspberry Pi**

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">

[![License](https://img.shields.io/badge/License-Custom-blue.svg)](LICENSE.md)
[![Platform](https://img.shields.io/badge/Platform-Raspberry%20Pi-red.svg)](https://www.raspberrypi.org/)
[![Protocol](https://img.shields.io/badge/Protocol-Alpaca%20%2F%20ASCOM-green.svg)](https://ascom-standards.org/)

---

## <i class="bi bi-bullseye"></i> **What is AlpacaPi?**

AlpacaPi is a comprehensive astronomy control system that transforms your Raspberry Pi into a powerful observatory controller. It provides ASCOM Alpaca protocol compatibility, allowing seamless integration with popular astronomy software like **NINA**, **SharpCap**, **PHD2**, and **SGP**.

### <i class="bi bi-star"></i> **Key Features**

- **<i class="bi bi-globe"></i> Alpaca Protocol**: Full ASCOM Alpaca compatibility for modern astronomy software
- **<i class="bi bi-camera"></i> Camera Support**: ZWO, ATIK, QHY, QSI, Touptek, FLIR, Sony, and more
- **<i class="bi bi-binoculars"></i> Telescope Control**: LX200, SkyWatcher, and custom mount protocols
- **<i class="bi bi-gear"></i> Accessory Control**: Focusers, filter wheels, domes, switches, and rotators
- **<i class="bi bi-rocket"></i> Ready-to-Deploy**: Custom Raspberry Pi OS images with pre-installed AlpacaPi
- **<i class="bi bi-puzzle"></i> Modular Design**: Install only the drivers you need
- **<i class="bi bi-phone"></i> Remote Control**: Web-based interface and API access

---

## <i class="bi bi-rocket"></i> **Quick Start**

### **Option 1: Node.js Build System (Recommended)**
```bash
# Clone the repository
git clone https://github.com/your-username/AlpacaPi.git
cd AlpacaPi

# Install dependencies and setup
npm install
npm run setup

# Build AlpacaPi
npm run build

# Build custom Raspberry Pi OS image
npm run build:pi-gen
```

### **Option 2: Pre-built Image**
```bash
# Download and flash custom AlpacaPi image
# See pi-gen/ directory for build instructions
```

### **Option 3: Traditional Build**
```bash
# Clone the repository
git clone https://github.com/your-username/AlpacaPi.git
cd AlpacaPi

# Setup and build
./scripts/setup.sh
sudo ./scripts/install_rules.sh
mkdir build && cd build
cmake .. && make -j4
```

---

## <i class="bi bi-list-check"></i> **Supported Devices**

### **<i class="bi bi-camera"></i> Cameras**
- **ZWO ASI** - All ASI cameras and accessories
- **ATIK** - Cameras and filter wheels
- **QHY** - CCD and CMOS cameras
- **QSI** - Professional CCD cameras
- **Touptek** - Budget-friendly cameras
- **FLIR** - Industrial and scientific cameras
- **Sony** - Mirrorless cameras (A7R IV, etc.)

### **<i class="bi bi-binoculars"></i> Telescope Mounts**
- **LX200** - Meade LX200 protocol
- **SkyWatcher** - SynScan protocol
- **Custom Mounts** - RoboClaw servo controllers

### **<i class="bi bi-gear"></i> Accessories**
- **Focusers**: Moonlite, ZWO EAF, custom servo
- **Filter Wheels**: ZWO EFW, ATIK, QSI
- **Domes**: Custom dome controllers
- **Switches**: Power and device control
- **Rotators**: Camera rotators and derotators

---

## <i class="bi bi-diagram-3"></i> **Project Structure**

```
AlpacaPi/
├── src/                    # Core source code
│   ├── core/              # Main AlpacaPi server
│   ├── net/               # Network protocols
│   ├── proto/             # Protocol implementations
│   └── util/              # Utilities and helpers
├── drivers/               # Device drivers (organized by manufacturer)
│   ├── zwo/               # ZWO ASI, EFW, EAF
│   ├── atik/              # ATIK cameras and accessories
│   ├── qhy/               # QHY cameras
│   ├── qsi/               # QSI cameras
│   ├── touptek/           # Touptek cameras
│   ├── flir/              # FLIR cameras
│   ├── sony/              # Sony cameras
│   ├── moonlite/          # Moonlite focusers and rotators
│   └── telescope_mounts/  # Telescope mount systems
├── pi-gen/                # Custom Raspberry Pi OS images
├── examples/              # Example applications
├── scripts/               # Traditional build and installation scripts
├── docs/                  # Documentation
├── package.json           # Node.js project configuration
├── build.js               # Main Node.js build script
├── docker-build.js        # Docker build script
├── setup.js               # Development setup script
├── test.js                # Test runner
├── clean.js               # Cleanup script
└── README_NODEJS.md       # Node.js build system documentation
```

---

## <i class="bi bi-tools"></i> **Build Systems**

### **Node.js Build System (Cross-Platform)**
AlpacaPi includes a modern Node.js build system that works on Windows, Linux, and Mac:

```bash
# Basic builds
npm run build                    # Default build
npm run build:debug             # Debug build
npm run build:release           # Release build
npm run build:pi                # Raspberry Pi build

# Development
npm run setup                   # Setup development environment
npm run test                    # Run tests
npm run clean                   # Clean build artifacts

# Docker builds
npm run docker:build            # Docker build
npm run docker:pi-gen           # Build RPi OS image
```

### **Custom Raspberry Pi OS Images**
Create ready-to-deploy images with AlpacaPi pre-installed:

```bash
# Using Node.js (recommended)
npm run build:pi-gen

# Using traditional method
cd pi-gen
./setup-pi-gen.sh
./build-alpacapi.sh
```

### **Image Variants**
- **AlpacaPi Lite**: Minimal server-only image
- **AlpacaPi Standard**: Common astronomy drivers
- **AlpacaPi Full**: All available drivers

---

## <i class="bi bi-gear"></i> **Node.js Build System Features**

### **Cross-Platform Support**
- **Windows**: Full support with Docker and native builds
- **Linux**: Native and Docker builds
- **Mac**: Native and Docker builds
- **Raspberry Pi**: Specialized pi-gen integration

### **Build Options**
```bash
# Platform-specific builds
npm run build -- --target windows
npm run build -- --target macos
npm run build -- --target linux
npm run build -- --target pi

# Build types
npm run build -- --type debug
npm run build -- --type release

# Docker builds
npm run build -- --docker
npm run docker:build

# Pi-gen builds
npm run build:pi-gen -- --image-type lite
npm run build:pi-gen -- --image-type standard
npm run build:pi-gen -- --image-type full
```

### **Development Tools**
- **Setup**: One-command development environment setup
- **Testing**: Comprehensive test runner with coverage support
- **Cleaning**: Smart cleanup of build artifacts
- **VS Code**: Pre-configured launch and task configurations
- **Git Hooks**: Pre-commit validation

---

## <i class="bi bi-book"></i> **Documentation**

- **[Main Documentation](https://msproul.github.io/AlpacaPi/)** - Complete user guide
- **[Node.js Build System](README_NODEJS.md)** - Cross-platform build documentation
- **[Driver Documentation](docs/drivers.html)** - Device-specific information
- **[API Reference](docs/alpacapi.pdf)** - Technical documentation
- **[Client Applications](docs/clientapps.html)** - GUI applications

---

## <i class="bi bi-code-slash"></i> **Development**

### **Prerequisites**
- **Node.js** 14.0.0+ (for Node.js build system)
- **CMake** 3.10+ (for native builds)
- **C++17** compatible compiler
- **OpenCV** 3.3.1+ or 4.5.1+ (for camera drivers)
- **cfitsio** (for FITS file support)
- **wiringPi** (Raspberry Pi only)
- **Docker** (optional, for containerized builds)

### **Node.js Build System (Recommended)**
```bash
# Setup development environment
npm install
npm run setup

# Build and test
npm run build
npm run test

# Clean and rebuild
npm run clean
npm run build:debug
```

### **Traditional Build System**
```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j4
```

### **Testing**
```bash
# Using Node.js build system
npm run test

# Using traditional method
make test
./test_camera_driver
./test_focuser_driver
```

---

## <i class="bi bi-graph-up"></i> **ASCOM Conformance**

AlpacaPi drivers have passed ASCOM CONFORM testing:

| Driver Type | Status | Date |
|-------------|--------|------|
| Camera (ZWO) | ✅ PASSED | Jan 2021 |
| Filter Wheel | ✅ PASSED | Apr 2020 |
| Focuser | ✅ PASSED | Apr 2020 |
| Rotator | ✅ PASSED | Apr 2020 |
| Switch | ✅ PASSED | Apr 2020 |
| Dome/ROR | ✅ PASSED | Jan 2021 |
| Observing Conditions | ✅ PASSED | Mar 2021 |
| Cover Calibrator | ✅ PASSED | Apr 2021 |

---

## <i class="bi bi-people"></i> **Contributing**

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### **Development Priorities**
1. <i class="bi bi-check-circle-fill text-success"></i> **Phase 1**: Modern C++ structure and organization
2. <i class="bi bi-check-circle-fill text-success"></i> **Phase 2**: Node.js build system and pi-gen integration
3. <i class="bi bi-arrow-clockwise text-warning"></i> **Phase 3**: Script architecture and modular installation
4. <i class="bi bi-list-check text-secondary"></i> **Phase 4**: Code modernization (C++17 features, RAII, smart pointers)
5. <i class="bi bi-list-check text-secondary"></i> **Phase 5**: Performance optimization and advanced features

---

## <i class="bi bi-file-text"></i> **License**

**Copyright (C) 2019-2024 by Mark Sproul**  
**Email**: msproul@skychariot.com

### **Usage Terms**
- ✅ **Private/Individual Use**: Granted
- ⚠️ **Commercial Use**: Requires written agreement
- 📝 **Modifications**: Allowed with attribution
- 🔄 **Redistribution**: Must retain copyright notice

**No warranty, obligations, or liability** - Use at your own risk.

---

## <i class="bi bi-heart"></i> **Acknowledgments**

- **Mark Sproul** - Original author and maintainer
- **ASCOM Standards** - Protocol specifications
- **Vendor SDKs** - Device driver libraries
- **Community** - Testing and feedback

---

## <i class="bi bi-headset"></i> **Support**

- **Documentation**: [https://msproul.github.io/AlpacaPi/](https://msproul.github.io/AlpacaPi/)
- **Issues**: [GitHub Issues](https://github.com/your-username/AlpacaPi/issues)
- **Email**: msproul@skychariot.com

---

## <i class="bi bi-gift"></i> **Donations**

If you find AlpacaPi useful, consider supporting the project:

- **PayPal**: msproul@skychariot.com
- **GitHub Sponsors**: [Sponsor Mark](https://github.com/sponsors/msproul)

---

## <i class="bi bi-lightning"></i> **Quick Reference**

### **Most Common Commands**
```bash
# Get started
npm install && npm run setup

# Build and test
npm run build && npm run test

# Build for Raspberry Pi
npm run build:pi

# Create custom RPi OS image
npm run build:pi-gen

# Clean everything
npm run clean -- --all
```

### **Advanced Commands**
```bash
# Debug build with verbose output
npm run build:debug -- --verbose

# Build for specific platform
npm run build -- --target windows --type release

# Docker builds
npm run docker:build
npm run docker:pi-gen -- --image-type full

# Test with coverage
npm run test -- --coverage
```

---

*AlpacaPi - Bringing professional astronomy control to the Raspberry Pi* <i class="bi bi-rocket"></i>