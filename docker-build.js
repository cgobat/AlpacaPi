#!/usr/bin/env node

/**
 * AlpacaPi Docker Build System
 * 
 * Specialized Docker build system for creating custom Raspberry Pi OS images
 * and cross-platform builds using Docker containers.
 */

const { execSync, spawn } = require('child_process');
const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');
const ora = require('ora');
const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');
const Docker = require('dockerode');

// Configuration
const config = {
  dockerImage: 'pi-gen-alpacapi',
  dockerContainer: 'pigen_work_alpacapi',
  piGenDir: 'pi-gen',
  buildDir: 'build',
  deployDir: 'deploy'
};

// Parse command line arguments
const argv = yargs(hideBin(process.argv))
  .option('pi-gen', {
    type: 'boolean',
    default: false,
    description: 'Build custom Raspberry Pi OS image using pi-gen'
  })
  .option('platform', {
    alias: 'p',
    type: 'string',
    choices: ['linux', 'windows', 'macos', 'pi'],
    default: 'pi',
    description: 'Target platform for pi-gen build'
  })
  .option('image-type', {
    alias: 'i',
    type: 'string',
    choices: ['lite', 'standard', 'full'],
    default: 'standard',
    description: 'Type of Raspberry Pi OS image to build'
  })
  .option('clean', {
    type: 'boolean',
    default: false,
    description: 'Clean build artifacts before building'
  })
  .option('verbose', {
    alias: 'v',
    type: 'boolean',
    default: false,
    description: 'Verbose output'
  })
  .help()
  .argv;

class DockerBuilder {
  constructor() {
    this.docker = new Docker();
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

  async checkDocker() {
    this.log('Checking Docker availability...');
    
    try {
      await this.docker.ping();
      this.log('Docker is running', 'success');
    } catch (error) {
      throw new Error('Docker is not running or not accessible');
    }
  }

  async cleanBuildArtifacts() {
    if (argv.clean) {
      this.log('Cleaning build artifacts...');
      
      // Clean build directory
      if (await fs.pathExists(config.buildDir)) {
        await fs.remove(config.buildDir);
        this.log('Build directory cleaned', 'success');
      }

      // Clean deploy directory
      if (await fs.pathExists(config.deployDir)) {
        await fs.remove(config.deployDir);
        this.log('Deploy directory cleaned', 'success');
      }

      // Clean pi-gen work directory
      const piGenWorkDir = path.join(config.piGenDir, 'work');
      if (await fs.pathExists(piGenWorkDir)) {
        await fs.remove(piGenWorkDir);
        this.log('pi-gen work directory cleaned', 'success');
      }
    }
  }

  async setupPiGen() {
    this.log('Setting up pi-gen...');
    
    // Check if pi-gen is already set up
    if (await fs.pathExists(path.join(config.piGenDir, 'setup-pi-gen.sh'))) {
      this.log('pi-gen already set up', 'success');
      return;
    }

    // Run setup script
    const spinner = ora('Setting up pi-gen').start();
    try {
      execSync(`cd ${config.piGenDir} && ./setup-pi-gen.sh`, {
        stdio: this.verbose ? 'inherit' : 'pipe'
      });
      spinner.succeed('pi-gen setup completed');
    } catch (error) {
      spinner.fail('pi-gen setup failed');
      throw error;
    }
  }

  async buildPiGenImage() {
    this.log('Building custom Raspberry Pi OS image...');
    
    // Update configuration based on image type
    await this.updatePiGenConfig();
    
    const spinner = ora('Building Raspberry Pi OS image').start();
    
    try {
      // Run pi-gen build
      execSync(`cd ${config.piGenDir} && ./build-alpacapi.sh`, {
        stdio: this.verbose ? 'inherit' : 'pipe'
      });
      
      spinner.succeed('Raspberry Pi OS image built successfully');
      
      // Show generated images
      await this.showGeneratedImages();
      
    } catch (error) {
      spinner.fail('Raspberry Pi OS image build failed');
      throw error;
    }
  }

  async updatePiGenConfig() {
    this.log('Updating pi-gen configuration...');
    
    const configFile = path.join(config.piGenDir, 'config');
    let configContent = await fs.readFile(configFile, 'utf8');
    
    // Update image name based on type
    const imageName = `AlpacaPi-${argv.imageType}`;
    configContent = configContent.replace(/IMG_NAME='.*'/, `IMG_NAME='${imageName}'`);
    
    // Update image description
    const imageDesc = `Raspberry Pi OS with AlpacaPi (${argv.imageType})`;
    configContent = configContent.replace(/IMG_DESC='.*'/, `IMG_DESC='${imageDesc}'`);
    
    // Update driver selection based on image type
    let drivers = '';
    switch (argv.imageType) {
      case 'lite':
        drivers = 'zwo';
        break;
      case 'standard':
        drivers = 'zwo atik qhy';
        break;
      case 'full':
        drivers = 'zwo atik qhy qsi touptek flir sony moonlite telescope_mounts observatory';
        break;
    }
    
    configContent = configContent.replace(/ALPACAPI_DRIVERS=".*"/, `ALPACAPI_DRIVERS="${drivers}"`);
    
    await fs.writeFile(configFile, configContent);
    this.log('pi-gen configuration updated', 'success');
  }

  async showGeneratedImages() {
    const deployDir = path.join(config.piGenDir, 'deploy');
    
    if (await fs.pathExists(deployDir)) {
      const files = await fs.readdir(deployDir);
      const imageFiles = files.filter(file => file.endsWith('.img'));
      
      if (imageFiles.length > 0) {
        this.log('Generated images:', 'success');
        imageFiles.forEach(file => {
          const filePath = path.join(deployDir, file);
          const stats = fs.statSync(filePath);
          const sizeInMB = (stats.size / (1024 * 1024)).toFixed(2);
          console.log(`  ${chalk.green('✓')} ${file} (${sizeInMB} MB)`);
        });
        
        this.log(`Images are ready to flash to SD cards!`, 'success');
        this.log(`Location: ${deployDir}`, 'info');
      }
    }
  }

  async buildCrossPlatform() {
    this.log('Building cross-platform AlpacaPi...');
    
    const spinner = ora('Building AlpacaPi for multiple platforms').start();
    
    try {
      // Build for different platforms
      const platforms = ['linux', 'windows', 'macos'];
      
      for (const platform of platforms) {
        this.log(`Building for ${platform}...`);
        
        // Create platform-specific Dockerfile
        await this.createPlatformDockerfile(platform);
        
        // Build Docker image
        const imageName = `alpacapi-${platform}`;
        execSync(`docker build -f Dockerfile.${platform} -t ${imageName} .`, {
          stdio: this.verbose ? 'inherit' : 'pipe'
        });
        
        // Run build
        execSync(`docker run --rm -v "$(pwd)":/workspace ${imageName}`, {
          stdio: this.verbose ? 'inherit' : 'pipe'
        });
        
        this.log(`Build completed for ${platform}`, 'success');
      }
      
      spinner.succeed('Cross-platform build completed');
      
    } catch (error) {
      spinner.fail('Cross-platform build failed');
      throw error;
    }
  }

  async createPlatformDockerfile(platform) {
    const dockerfile = `
# AlpacaPi Builder for ${platform}
FROM ubuntu:24.04

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

# Install OpenCV
RUN apt-get update && apt-get install -y \\
    libopencv-dev \\
    libopencv-contrib-dev \\
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . /workspace/

# Build script
RUN echo '#!/bin/bash' > /workspace/build.sh && \\
    echo 'set -e' >> /workspace/build.sh && \\
    echo 'mkdir -p build' >> /workspace/build.sh && \\
    echo 'cd build' >> /workspace/build.sh && \\
    echo 'cmake .. -DCMAKE_BUILD_TYPE=Release' >> /workspace/build.sh && \\
    echo 'make -j$(nproc)' >> /workspace/build.sh && \\
    echo 'make test' >> /workspace/build.sh && \\
    chmod +x /workspace/build.sh

CMD ["/workspace/build.sh"]
`;

    await fs.writeFile(`Dockerfile.${platform}`, dockerfile);
    this.log(`Dockerfile created for ${platform}`, 'success');
  }

  async showBuildInfo() {
    this.log('Docker Build Configuration:', 'info');
    console.log(`  Pi-Gen Build: ${chalk.cyan(argv.piGen)}`);
    console.log(`  Platform: ${chalk.cyan(argv.platform)}`);
    console.log(`  Image Type: ${chalk.cyan(argv.imageType)}`);
    console.log(`  Clean Build: ${chalk.cyan(argv.clean)}`);
    console.log(`  Verbose: ${chalk.cyan(argv.verbose)}`);
    console.log('');
  }

  async build() {
    try {
      this.log('Starting Docker build...');
      await this.showBuildInfo();
      
      await this.checkDocker();
      await this.cleanBuildArtifacts();

      if (argv.piGen) {
        await this.setupPiGen();
        await this.buildPiGenImage();
      } else {
        await this.buildCrossPlatform();
      }

      this.log('Docker build completed successfully!', 'success');
      
    } catch (error) {
      this.log(`Docker build failed: ${error.message}`, 'error');
      process.exit(1);
    }
  }
}

// Main execution
if (require.main === module) {
  const builder = new DockerBuilder();
  builder.build();
}

module.exports = DockerBuilder;
