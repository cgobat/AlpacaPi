# AlpacaPi Custom Raspberry Pi OS Images

This directory contains the pi-gen configuration for building custom Raspberry Pi OS images with AlpacaPi pre-installed.

## 🎯 **Goals**
- Create ready-to-deploy RPi OS images with AlpacaPi
- Optimized for NINA control (no client apps)
- Minimal resource usage
- Easy driver selection and installation

## 📁 **Directory Structure**
```
pi-gen/
├── README_ALPACAPI.md           # This file
├── config_alpacapi              # AlpacaPi-specific config
├── stage-alpacapi/              # Custom AlpacaPi installation stage
│   ├── 00-run.sh               # Main installation script
│   ├── 01-install-deps.sh      # Install system dependencies
│   ├── 02-install-alpacapi.sh  # Install AlpacaPi
│   ├── 03-configure.sh         # Configure AlpacaPi
│   └── 04-enable-services.sh   # Enable services
├── build-alpacapi.sh            # Build script for AlpacaPi images
└── docker/
    ├── Dockerfile.alpacapi      # Custom Docker image
    └── build-docker-alpacapi.sh # Docker build script
```

## 🚀 **Quick Start**

### **Build Custom Image**
```bash
# Clone pi-gen (if not already done)
git clone https://github.com/RPi-Distro/pi-gen.git

# Copy AlpacaPi configuration
cp config_alpacapi pi-gen/config

# Build image
cd pi-gen
./build-docker-alpacapi.sh
```

### **Available Image Variants**
- **alpacapi-lite**: Minimal image with AlpacaPi server only
- **alpacapi-standard**: Common astronomy drivers (ZWO, ATIK, QHY)
- **alpacapi-full**: All available drivers

## ⚙️ **Configuration Options**

### **Driver Selection**
Edit `stage-alpacapi/02-install-alpacapi.sh` to select drivers:
```bash
# Minimal (ZWO ASI only)
DRIVERS="zwo"

# Standard (common astronomy)
DRIVERS="zwo atik qhy"

# Full (all drivers)
DRIVERS="zwo atik qhy qsi touptek flir sony moonlite telescope_mounts observatory"
```

### **Build Options**
Edit `config_alpacapi`:
```bash
# Image name
IMG_NAME='AlpacaPi'

# Image description
IMG_DESC='Raspberry Pi OS with AlpacaPi for NINA Control'

# Enable/disable features
ENABLE_SSH=1
ENABLE_VNC=0
ENABLE_DESKTOP=0
```

## 🔧 **Customization**

### **Adding New Drivers**
1. Add driver installation to `stage-alpacapi/02-install-alpacapi.sh`
2. Add udev rules to `stage-alpacapi/03-configure.sh`
3. Test with minimal image first

### **Modifying Services**
Edit `stage-alpacapi/04-enable-services.sh` to:
- Configure AlpacaPi startup options
- Set up auto-discovery
- Configure network settings

## 📋 **Build Process**

1. **Stage 0-2**: Standard RPi OS Lite base
2. **Stage AlpacaPi**: Custom AlpacaPi installation
   - Install system dependencies
   - Clone and build AlpacaPi
   - Install selected drivers
   - Configure services
   - Set up auto-start

## 🐳 **Docker Build**

The Docker approach provides:
- Consistent build environment
- Cross-platform compatibility
- Isolated build process
- Easy CI/CD integration

## 📝 **Notes**

- Images are optimized for headless operation
- SSH enabled by default for remote access
- AlpacaPi starts automatically on boot
- Ready for NINA discovery and control

---
*Last Updated: [Current Date]*
*Status: Planning Phase*
