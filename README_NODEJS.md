# AlpacaPi Node.js Build System

**Cross-platform build system for AlpacaPi using Node.js and Docker**

This Node.js build system provides a unified, cross-platform development experience for AlpacaPi across Windows, Linux, and Mac.

## <i class="bi bi-rocket"></i> **Quick Start**

### **Prerequisites: Installing Node.js**

Before using the Node.js build system, you need to install Node.js and npm. Here are the installation instructions for different platforms:

#### **Windows**
1. **Download Node.js**:
   - Go to [nodejs.org](https://nodejs.org/)
   - Download the LTS version (recommended)
   - Run the installer and follow the setup wizard

2. **Verify Installation**:
   ```cmd
   node --version
   npm --version
   ```

3. **Alternative: Using Chocolatey**:
   ```cmd
   choco install nodejs
   ```

#### **macOS**
1. **Using Homebrew (Recommended)**:
   ```bash
   # Install Homebrew if you don't have it
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   
   # Install Node.js
   brew install node
   ```

2. **Using Official Installer**:
   - Go to [nodejs.org](https://nodejs.org/)
   - Download the macOS installer
   - Run the `.pkg` file and follow the setup wizard

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

#### **Linux (Ubuntu/Debian)**
1. **Using NodeSource Repository**:
   ```bash
   # Update package index
   sudo apt update
   
   # Install curl if not already installed
   sudo apt install -y curl
   
   # Add NodeSource repository
   curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
   
   # Install Node.js
   sudo apt install -y nodejs
   ```

2. **Using Snap**:
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

#### **Raspberry Pi (Target Platform Only)**
**Note**: You don't need to install Node.js on the Raspberry Pi itself. The Node.js build system runs on your development machine (PC/Mac) and creates a custom Raspberry Pi OS image that you can flash to an SD card.

The Raspberry Pi will run the pre-built AlpacaPi software from the custom image, not the Node.js build system.

#### **Verify Installation**
After installing Node.js, verify the installation:
```bash
# Check Node.js version (should be 14.0.0 or higher)
node --version

# Check npm version (should be 6.0.0 or higher)
npm --version

# Check if npm is working
npm --help
```

### **Installation**
```bash
# Install Node.js dependencies
npm install

# Setup development environment
npm run setup

# Build AlpacaPi
npm run build

# Run tests
npm run test

# Build Raspberry Pi OS image
npm run build:pi-gen
```

## <i class="bi bi-list-check"></i> **Available Scripts**

### **Build Scripts**
- `npm run build` - Build AlpacaPi (default: release, Linux)
- `npm run build:debug` - Build in debug mode
- `npm run build:release` - Build in release mode
- `npm run build:pi` - Build AlpacaPi for Raspberry Pi (cross-compile)
- `npm run build:pi-gen` - Create custom Raspberry Pi OS image with AlpacaPi pre-installed

### **Development Scripts**
- `npm run setup` - Setup development environment
- `npm run test` - Run all tests
- `npm run clean` - Clean build artifacts
- `npm run docker:build` - Build using Docker
- `npm run docker:pi-gen` - Build RPi image using Docker

## <i class="bi bi-gear"></i> **Build Options**

### **Target Platforms**
```bash
# Build for specific platform (on your development machine)
npm run build -- --target linux
npm run build -- --target windows
npm run build -- --target macos
npm run build -- --target pi        # Cross-compile for Raspberry Pi
npm run build -- --target all

# Create Raspberry Pi OS image (runs on your development machine)
npm run build:pi-gen                # Creates flashable SD card image
```

### **Build Types**
```bash
# Debug build
npm run build -- --type debug

# Release build
npm run build -- --type release
```

### **Docker Options**
```bash
# Use Docker for building
npm run build -- --docker

# Build natively (no Docker)
npm run build -- --no-docker
```

### **Pi-Gen Options**
```bash
# Build custom RPi OS image
npm run build:pi-gen

# Build specific image type
npm run docker:pi-gen -- --image-type lite
npm run docker:pi-gen -- --image-type standard
npm run docker:pi-gen -- --image-type full
```

## <i class="bi bi-code-slash"></i> **Development Workflow**

### **Complete Workflow: PC → Raspberry Pi**

The AlpacaPi Node.js build system is designed to run on your development machine (PC/Mac) and create a ready-to-flash Raspberry Pi OS image. Here's the complete workflow:

1. **Develop on PC/Mac** → 2. **Build with Docker** → 3. **Create RPi Image** → 4. **Flash SD Card** → 5. **Deploy to Raspberry Pi**

### **1. Initial Setup (on your development machine)**
```bash
# Clone repository
git clone https://github.com/your-username/AlpacaPi.git
cd AlpacaPi

# Install Node.js dependencies
npm install

# Setup development environment
npm run setup
```

### **2. Development**
```bash
# Build in debug mode
npm run build:debug

# Run tests
npm run test

# Clean and rebuild
npm run clean && npm run build
```

### **3. Testing**
```bash
# Run all tests
npm run test

# Run specific test types
npm run test -- --type unit
npm run test -- --type integration
npm run test -- --type driver

# Run with coverage
npm run test -- --coverage
```

### **4. Building for Production**
```bash
# Build release version (on your development machine)
npm run build:release

# Cross-compile for Raspberry Pi (on your development machine)
npm run build:pi

# Create custom Raspberry Pi OS image (on your development machine)
npm run build:pi-gen

# This creates a flashable image in pi-gen/deploy/
# Use Raspberry Pi Imager to flash the image to an SD card
```

### **5. Deploying to Raspberry Pi**
```bash
# After building the image, flash it to an SD card:
# 1. Download Raspberry Pi Imager from https://www.raspberrypi.org/downloads/
# 2. Select "Use custom image" and choose the image from pi-gen/deploy/
# 3. Flash to SD card
# 4. Insert SD card into Raspberry Pi and boot

# The Raspberry Pi will automatically start AlpacaPi on boot
# No additional installation needed on the Raspberry Pi!
```

## <i class="bi bi-docker"></i> **Docker Integration**

### **Docker Builds**
The Node.js build system uses Docker to ensure consistent builds across platforms:

```bash
# Build using Docker (on your development machine)
npm run docker:build

# Build RPi image using Docker (on your development machine)
npm run docker:pi-gen
```

### **Docker Images**
- `alpacapi-builder` - Main build image
- `pi-gen-alpacapi` - Raspberry Pi OS image builder
- `alpacapi-tester` - Test environment

## <i class="bi bi-sd-card"></i> **Raspberry Pi Deployment**

### **Complete Deployment Workflow**

1. **Build on Development Machine**:
   ```bash
   # Create custom Raspberry Pi OS image
   npm run build:pi-gen
   
   # Image will be created in: pi-gen/deploy/
   # Example: pi-gen/deploy/2024-09-07-AlpacaPi-lite.img
   ```

2. **Flash to SD Card**:
   - Download [Raspberry Pi Imager](https://www.raspberrypi.org/downloads/)
   - Select "Use custom image"
   - Choose the `.img` file from `pi-gen/deploy/`
   - Select your SD card and flash

3. **Deploy to Raspberry Pi**:
   - Insert SD card into Raspberry Pi
   - Power on the Raspberry Pi
   - AlpacaPi starts automatically on boot
   - Access via web interface or NINA

### **Image Variants**
- **Lite**: Minimal server-only image (~2GB)
- **Standard**: Common astronomy drivers (~4GB)
- **Full**: All available drivers (~6GB)

## <i class="bi bi-puzzle"></i> **Project Structure**

```
AlpacaPi/
├── package.json              # Node.js configuration
├── build.js                  # Main build script
├── docker-build.js           # Docker build script
├── setup.js                  # Setup script
├── test.js                   # Test runner
├── clean.js                  # Cleanup script
├── src/                      # Source code
├── drivers/                  # Device drivers
├── pi-gen/                   # Raspberry Pi OS images
├── build/                    # Build artifacts
├── tests/                    # Test files
└── docs/                     # Documentation
```

## <i class="bi bi-tools"></i> **Advanced Usage**

### **Custom Build Configuration**
```bash
# Verbose output
npm run build -- --verbose

# Clean build
npm run build -- --clean

# Specific driver
npm run test -- --driver zwo
```

### **Cross-Platform Building**
```bash
# Build for all platforms
npm run build -- --target all

# Build for specific platform
npm run build -- --target windows --type release
```

### **Pi-Gen Customization**
```bash
# Build lite image
npm run docker:pi-gen -- --image-type lite

# Build full image
npm run docker:pi-gen -- --image-type full

# Clean pi-gen artifacts
npm run clean -- --pi-gen
```

## <i class="bi bi-shield-check"></i> **Prerequisites**

### **Required**
- **Node.js** 14.0.0+
- **npm** 6.0.0+
- **Git**
- **Docker** (for Docker builds)

### **Optional**
- **CMake** (for native builds)
- **C++ Compiler** (for native builds)
- **OpenCV** (for camera drivers)

## <i class="bi bi-question-circle"></i> **Troubleshooting**

### **Common Issues**

#### **Node.js Installation Issues**
```bash
# Check if Node.js is installed
node --version
npm --version

# If not found, reinstall Node.js
# Windows: Download from nodejs.org
# Mac: brew install node
# Linux: curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt install -y nodejs

# Clear npm cache if having issues
npm cache clean --force

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

#### **Permission Issues (Linux/macOS)**
```bash
# Fix npm permissions
sudo chown -R $(whoami) ~/.npm
sudo chown -R $(whoami) /usr/local/lib/node_modules

# Or use a Node version manager (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts
```

#### **Docker Not Running**
```bash
# Start Docker
# Windows: Start Docker Desktop
# Mac: Start Docker Desktop
# Linux: sudo systemctl start docker
```

#### **Build Failures**
```bash
# Clean and rebuild
npm run clean
npm run build

# Check verbose output
npm run build -- --verbose

# Check if all dependencies are installed
npm install
```

#### **Test Failures**
```bash
# Run tests with verbose output
npm run test -- --verbose

# Run specific test type
npm run test -- --type unit
```

### **Getting Help**
- Check the [main documentation](https://msproul.github.io/AlpacaPi/)
- Open an [issue](https://github.com/your-username/AlpacaPi/issues)
- Check the [contributing guide](CONTRIBUTING.md)

## <i class="bi bi-heart"></i> **Contributing**

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### **Development Setup**
```bash
# Fork and clone repository
git clone https://github.com/your-username/AlpacaPi.git
cd AlpacaPi

# Install dependencies
npm install

# Setup development environment
npm run setup

# Make your changes
# ...

# Run tests
npm run test

# Submit pull request
```

---

*AlpacaPi Node.js Build System - Cross-platform development made easy* <i class="bi bi-rocket"></i>
