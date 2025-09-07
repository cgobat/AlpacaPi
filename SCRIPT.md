# AlpacaPi Script Architecture & Goals

## 🎯 **Project Goals**
- **Primary**: Deploy AlpacaPi on Raspberry Pi for NINA control
- **Secondary**: Provide modular driver installation system
- **Tertiary**: Support advanced users with full feature set

## 📋 **Current Script Status**

### ❌ **Issues Identified**
1. **Vendor Library Mismatch**: Scripts expect libraries in root, but we moved them to `drivers/`
2. **Client App Focus**: Scripts heavily focused on GUI apps (not needed for NINA)
3. **Monolithic Approach**: `install_everything.sh` tries to install all drivers at once
4. **OpenCV Dependency**: Required for client apps we don't need

### ✅ **What Works**
- CMake build system (tested successfully)
- Core AlpacaPi server functionality
- Driver source code organization

## 🏗️ **Proposed Script Architecture**

### **1. Main Entry Point**
```bash
scripts/install_alpacapi.sh
```
- Interactive driver selection
- System dependency management
- Build configuration
- Usage: `./install_alpacapi.sh [options] [drivers...]`

### **2. Modular Structure**
```
scripts/
├── install_alpacapi.sh          # Main entry point
├── install/
│   ├── install_system.sh        # System deps (libusb, cfitsio, etc.)
│   ├── install_zwo.sh           # ZWO cameras, filter wheels, focusers
│   ├── install_atik.sh          # ATIK cameras and filter wheels
│   ├── install_qhy.sh           # QHY cameras
│   ├── install_qsi.sh           # QSI cameras
│   ├── install_touptek.sh       # Touptek cameras
│   ├── install_flir.sh          # FLIR cameras
│   ├── install_sony.sh          # Sony DSLR cameras
│   ├── install_moonlite.sh      # Moonlite focusers and rotators
│   ├── install_telescope_mounts.sh # Telescope mount drivers
│   └── install_observatory.sh   # Observatory equipment (IMU, etc.)
├── build/
│   ├── build_server.sh          # Server-only build (no client apps)
│   ├── build_minimal.sh         # Minimal build for RPi
│   └── build_all.sh             # Full build (if needed)
└── legacy/                      # Move old scripts here
    ├── build_all.sh
    ├── install_everything.sh
    └── ...
```

## 🎮 **Interactive Installation Flow**

### **Driver Selection Menu**
```
AlpacaPi Installation Script
============================

Available Drivers:
[1] ZWO Cameras (ASI, EFW, EAF)     [6] Sony DSLR Cameras
[2] ATIK Cameras & Filter Wheels    [7] Moonlite Focusers
[3] QHY Cameras                     [8] Telescope Mounts
[4] QSI Cameras                     [9] Observatory Equipment
[5] Touptek Cameras                 [0] All Drivers

Options:
[I] Install selected drivers
[B] Build server only
[L] List installed drivers
[Q] Quit

Enter selection: _
```

### **Installation Modes**
- **Minimal**: Essential drivers only (ZWO ASI)
- **Standard**: Common astronomy drivers (ZWO, ATIK, QHY)
- **Full**: All available drivers
- **Custom**: User-selected drivers

## 🔧 **Technical Requirements**

### **System Dependencies**
- libusb-1.0-0-dev
- libudev-dev
- libi2c-dev
- libcfitsio-dev
- cmake, gcc, g++

### **Vendor Library Handling**
- Download vendor SDKs to `drivers/[manufacturer]/`
- Install libraries to system directories
- Set up udev rules
- Verify installation

### **Build Configuration**
- **Server-only**: No OpenCV, no client apps
- **Minimal**: Essential features only
- **Full**: All features (if requested)

## 📝 **Implementation Plan**

### **Phase 1: Fix Current Issues**
1. Update script paths to match new directory structure
2. Create vendor library download/installation system
3. Test with minimal driver set

### **Phase 2: Create New Architecture**
1. Design interactive installation script
2. Create modular driver installation scripts
3. Update CMakeLists.txt for server-only builds

### **Phase 3: Testing & Validation**
1. Test on clean RPi system
2. Validate NINA connectivity
3. Document installation process

## 🎯 **Success Criteria**
- [ ] Single command installation: `./install_alpacapi.sh`
- [ ] NINA can discover and control AlpacaPi devices
- [ ] Minimal resource usage on RPi
- [ ] Easy driver selection and installation
- [ ] Clear documentation and error messages

## 📚 **Documentation Files**
- `CURSOR.md` - Project overview and directory structure
- `SCRIPT.md` - This file (script architecture and goals)
- `INSTALL.md` - User installation guide
- `DEVELOPER.md` - Developer documentation

---
*Last Updated: [Current Date]*
*Status: Planning Phase*
