#!/usr/bin/env node

/**
 * AlpacaPi Cross-Platform Build System
 * 
 * This script provides a unified build experience across Windows, Linux, and Mac
 * using Docker for consistent builds and Node.js for cross-platform compatibility.
 */

const { execSync, spawn } = require('child_process');
const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');
const ora = require('ora');
const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');

// Configuration
const config = {
  projectName: 'AlpacaPi',
  buildDir: 'build',
  dockerImage: 'alpacapi-builder',
  dockerContainer: 'alpacapi-build-container',
  platforms: {
    linux: 'linux/amd64',
    windows: 'windows/amd64',
    macos: 'darwin/amd64',
    pi: 'linux/arm64'
  }
};

// Parse command line arguments
const argv = yargs(hideBin(process.argv))
  .option('target', {
    alias: 't',
    type: 'string',
    choices: ['linux', 'windows', 'macos', 'pi', 'all'],
    default: 'linux',
    description: 'Target platform to build for'
  })
  .option('type', {
    alias: 'T',
    type: 'string',
    choices: ['debug', 'release'],
    default: 'release',
    description: 'Build type'
  })
  .option('pi-gen', {
    type: 'boolean',
    default: false,
    description: 'Build custom Raspberry Pi OS image'
  })
  .option('clean', {
    type: 'boolean',
    default: false,
    description: 'Clean build directory before building'
  })
  .option('docker', {
    type: 'boolean',
    default: true,
    description: 'Use Docker for building'
  })
  .option('verbose', {
    alias: 'v',
    type: 'boolean',
    default: false,
    description: 'Verbose output'
  })
  .help()
  .argv;

class AlpacaPiBuilder {
  constructor() {
    this.isWindows = process.platform === 'win32';
    this.isMacOS = process.platform === 'darwin';
    this.isLinux = process.platform === 'linux';
    this.verbose = argv.verbose;
  }

  log(message, type = 'info') {
    const timestamp = new Date().toISOString();
    const prefix = `[${timestamp}]`;
    
    switch (type) {
      case 'info':
        console.log(chalk.blue(`${prefix} ℹ️  ${message}`));
        break;
      case 'success':
        console.log(chalk.green(`${prefix} ✅ ${message}`));
        break;
      case 'warning':
        console.log(chalk.yellow(`${prefix} ⚠️  ${message}`));
        break;
      case 'error':
        console.log(chalk.red(`${prefix} ❌ ${message}`));
        break;
      case 'debug':
        if (this.verbose) {
          console.log(chalk.gray(`${prefix} 🐛 ${message}`));
        }
        break;
    }
  }

  async checkPrerequisites() {
    this.log('Checking prerequisites...');
    
    // Check Node.js version
    const nodeVersion = process.version;
    const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);
    if (majorVersion < 14) {
      throw new Error(`Node.js 14+ required, found ${nodeVersion}`);
    }
    this.log(`Node.js version: ${nodeVersion}`, 'success');

    // Check Docker (only if using Docker)
    if (argv.docker) {
      try {
        const dockerVersion = execSync('docker --version', { encoding: 'utf8' });
        this.log(`Docker version: ${dockerVersion.trim()}`, 'success');
      } catch (error) {
        throw new Error('Docker is not installed or not running');
      }

      // Check if Docker is running
      try {
        execSync('docker info', { stdio: 'ignore' });
        this.log('Docker is running', 'success');
      } catch (error) {
        throw new Error('Docker is not running. Please start Docker and try again.');
      }
    } else {
      this.log('Skipping Docker check (using native build)', 'info');
    }

    // Check CMake
    try {
      const cmakeVersion = execSync('cmake --version', { encoding: 'utf8' });
      this.log(`CMake version: ${cmakeVersion.split('\n')[0]}`, 'success');
    } catch (error) {
      this.log('CMake not found, will use Docker for building', 'warning');
    }
  }

  async cleanBuildDirectory() {
    if (argv.clean) {
      this.log('Cleaning build directory...');
      await fs.remove(config.buildDir);
      this.log('Build directory cleaned', 'success');
    }
  }

  async createDockerfile() {
    const dockerfile = `
# AlpacaPi Cross-Platform Builder
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install dependencies
RUN apt-get update && apt-get install -y \\
    build-essential \\
    cmake \\
    git \\
    wget \\
    curl \\
    unzip \\
    pkg-config \\
    libusb-1.0-0-dev \\
    libudev-dev \\
    libi2c-dev \\
    libcfitsio-dev \\
    libjpeg-dev \\
    libpng-dev \\
    libssl-dev \\
    libffi-dev \\
    python3 \\
    python3-pip \\
    python3-dev \\
    && rm -rf /var/lib/apt/lists/*

# Install OpenCV (for camera drivers)
RUN apt-get update && apt-get install -y \\
    libopencv-dev \\
    libopencv-contrib-dev \\
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
`;

    await fs.writeFile('Dockerfile.builder', dockerfile);
    this.log('Dockerfile created', 'success');
  }

  async createBuildScript() {
    const buildScript = `#!/bin/bash
set -e

echo "Starting AlpacaPi build in Docker..."

# Create build directory
mkdir -p build
cd build

# Configure with CMake
echo "Configuring with CMake..."
cmake .. \\
    -DCMAKE_BUILD_TYPE=${argv.type.toUpperCase()} \\
    -DBUILD_CLIENT_APPS=OFF \\
    -DBUILD_EXAMPLES=ON \\
    -DBUILD_TESTS=ON

# Build
echo "Building AlpacaPi..."
make -j$(nproc)

# Run tests
echo "Running tests..."
make test

echo "Build completed successfully!"
`;

    await fs.writeFile('build-docker.sh', buildScript);
    await fs.chmod('build-docker.sh', '755');
    this.log('Build script created', 'success');
  }

  async buildDockerImage() {
    this.log('Building Docker image...');
    const spinner = ora('Building Docker image').start();
    
    try {
      execSync(`docker build -f Dockerfile.builder -t ${config.dockerImage} .`, {
        stdio: this.verbose ? 'inherit' : 'pipe'
      });
      spinner.succeed('Docker image built successfully');
    } catch (error) {
      spinner.fail('Failed to build Docker image');
      throw error;
    }
  }

  async runDockerBuild() {
    this.log('Running Docker build...');
    const spinner = ora('Building AlpacaPi in Docker').start();
    
    try {
      // Remove existing container if it exists
      try {
        execSync(`docker rm -f ${config.dockerContainer}`, { stdio: 'ignore' });
      } catch (error) {
        // Container doesn't exist, that's fine
      }

      // Run build in Docker
      execSync(`docker run --name ${config.dockerContainer} -v "$(pwd)":/workspace ${config.dockerImage}`, {
        stdio: this.verbose ? 'inherit' : 'pipe'
      });

      // Copy build artifacts back
      execSync(`docker cp ${config.dockerContainer}:/workspace/build .`);

      // Clean up container
      execSync(`docker rm ${config.dockerContainer}`);

      spinner.succeed('Docker build completed successfully');
    } catch (error) {
      spinner.fail('Docker build failed');
      throw error;
    }
  }

  async buildPiGen() {
    if (!argv.piGen) return;

    this.log('Building custom Raspberry Pi OS image...');
    const spinner = ora('Building pi-gen image').start();
    
    try {
      // Check if pi-gen is set up
      if (!await fs.pathExists('pi-gen/setup-pi-gen.sh')) {
        throw new Error('pi-gen not set up. Run: npm run setup');
      }

      // Run pi-gen build
      execSync('cd pi-gen && ./build-alpacapi.sh', {
        stdio: this.verbose ? 'inherit' : 'pipe'
      });

      spinner.succeed('Raspberry Pi OS image built successfully');
    } catch (error) {
      spinner.fail('pi-gen build failed');
      throw error;
    }
  }

  async buildNative() {
    this.log('Building natively (without Docker)...');
    
    // Create build directory
    await fs.ensureDir(config.buildDir);
    
    // Configure with CMake
    this.log('Configuring with CMake...');
    execSync(`cmake -B ${config.buildDir} -DCMAKE_BUILD_TYPE=${argv.type}`, {
      stdio: this.verbose ? 'inherit' : 'pipe'
    });

    // Build
    this.log('Building AlpacaPi...');
    execSync(`cmake --build ${config.buildDir} --parallel`, {
      stdio: this.verbose ? 'inherit' : 'pipe'
    });

    // Run tests (if test target exists)
    this.log('Running tests...');
    try {
      execSync(`cmake --build ${config.buildDir} --target test`, {
        stdio: this.verbose ? 'inherit' : 'pipe'
      });
    } catch (error) {
      this.log('No test target found, skipping tests', 'warning');
    }

    this.log('Native build completed successfully', 'success');
  }

  async showBuildInfo() {
    this.log('Build Configuration:', 'info');
    console.log(`  Target Platform: ${chalk.cyan(argv.target)}`);
    console.log(`  Build Type: ${chalk.cyan(argv.type)}`);
    console.log(`  Use Docker: ${chalk.cyan(argv.docker)}`);
    console.log(`  Pi-Gen Build: ${chalk.cyan(argv.piGen)}`);
    console.log(`  Clean Build: ${chalk.cyan(argv.clean)}`);
    console.log(`  Verbose: ${chalk.cyan(argv.verbose)}`);
    console.log('');
  }

  async build() {
    try {
      this.log(`Starting ${config.projectName} build...`);
      await this.showBuildInfo();
      
      await this.checkPrerequisites();
      await this.cleanBuildDirectory();

      if (argv.piGen) {
        await this.buildPiGen();
      } else if (argv.docker) {
        await this.createDockerfile();
        await this.createBuildScript();
        await this.buildDockerImage();
        await this.runDockerBuild();
      } else {
        await this.buildNative();
      }

      this.log('Build completed successfully!', 'success');
      
      // Show build artifacts
      if (await fs.pathExists(config.buildDir)) {
        const files = await fs.readdir(config.buildDir);
        this.log('Build artifacts:', 'info');
        files.forEach(file => {
          console.log(`  ${chalk.green('✓')} ${file}`);
        });
      }

    } catch (error) {
      this.log(`Build failed: ${error.message}`, 'error');
      process.exit(1);
    }
  }
}

// Main execution
if (require.main === module) {
  const builder = new AlpacaPiBuilder();
  builder.build();
}

module.exports = AlpacaPiBuilder;
