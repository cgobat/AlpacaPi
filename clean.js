#!/usr/bin/env node

/**
 * AlpacaPi Clean Script
 * 
 * Cross-platform cleanup script for AlpacaPi build artifacts
 */

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
  testDir: 'tests',
  deployDir: 'deploy',
  piGenDir: 'pi-gen',
  tempDir: 'temp',
  logsDir: 'logs'
};

// Parse command line arguments
const argv = yargs(hideBin(process.argv))
  .option('all', {
    alias: 'a',
    type: 'boolean',
    default: false,
    description: 'Clean all build artifacts'
  })
  .option('build', {
    type: 'boolean',
    default: true,
    description: 'Clean build directory'
  })
  .option('test', {
    type: 'boolean',
    default: false,
    description: 'Clean test artifacts'
  })
  .option('docker', {
    type: 'boolean',
    default: false,
    description: 'Clean Docker images and containers'
  })
  .option('pi-gen', {
    type: 'boolean',
    default: false,
    description: 'Clean pi-gen artifacts'
  })
  .option('temp', {
    type: 'boolean',
    default: true,
    description: 'Clean temporary files'
  })
  .option('logs', {
    type: 'boolean',
    default: false,
    description: 'Clean log files'
  })
  .option('artifacts', {
    type: 'boolean',
    default: true,
    description: 'Clean build artifacts (object files, libraries, etc.)'
  })
  .option('force', {
    alias: 'f',
    type: 'boolean',
    default: false,
    description: 'Force clean without confirmation'
  })
  .option('verbose', {
    alias: 'v',
    type: 'boolean',
    default: false,
    description: 'Verbose output'
  })
  .help()
  .argv;

class AlpacaPiCleaner {
  constructor() {
    this.verbose = argv.verbose;
    this.cleanedItems = [];
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

  async cleanDirectory(dirPath, description) {
    if (await fs.pathExists(dirPath)) {
      const spinner = ora(`Cleaning ${description}`).start();
      try {
        await fs.remove(dirPath);
        this.cleanedItems.push(description);
        spinner.succeed(`${description} cleaned`);
      } catch (error) {
        spinner.fail(`Failed to clean ${description}`);
        this.log(`Error cleaning ${dirPath}: ${error.message}`, 'error');
      }
    } else {
      this.log(`${description} not found, skipping`, 'debug');
    }
  }

  async cleanBuildDirectory() {
    if (argv.build || argv.all) {
      await this.cleanDirectory(config.buildDir, 'Build directory');
    }
  }

  async cleanTestArtifacts() {
    if (argv.test || argv.all) {
      await this.cleanDirectory(config.testDir, 'Test directory');
      
      // Clean test executables from build directory
      if (await fs.pathExists(config.buildDir)) {
        const files = await fs.readdir(config.buildDir);
        const testFiles = files.filter(file => 
          file.startsWith('test_') || 
          file.includes('_test') ||
          file.endsWith('.test')
        );
        
        for (const file of testFiles) {
          const filePath = path.join(config.buildDir, file);
          try {
            await fs.remove(filePath);
            this.cleanedItems.push(`Test file: ${file}`);
          } catch (error) {
            this.log(`Error removing test file ${file}: ${error.message}`, 'error');
          }
        }
      }
    }
  }

  async cleanDockerArtifacts() {
    if (argv.docker || argv.all) {
      this.log('Cleaning Docker artifacts...');
      const spinner = ora('Cleaning Docker artifacts').start();
      
      try {
        // Remove Docker images
        const { execSync } = require('child_process');
        
        // List and remove AlpacaPi-related images
        try {
          const images = execSync('docker images --format "{{.Repository}}:{{.Tag}}" | grep alpacapi', { encoding: 'utf8' });
          const imageList = images.trim().split('\n').filter(img => img.length > 0);
          
          for (const image of imageList) {
            try {
              execSync(`docker rmi ${image}`, { stdio: 'ignore' });
              this.cleanedItems.push(`Docker image: ${image}`);
            } catch (error) {
              this.log(`Error removing Docker image ${image}: ${error.message}`, 'warning');
            }
          }
        } catch (error) {
          // No images found, that's fine
        }
        
        // Remove Docker containers
        try {
          const containers = execSync('docker ps -a --format "{{.Names}}" | grep alpacapi', { encoding: 'utf8' });
          const containerList = containers.trim().split('\n').filter(container => container.length > 0);
          
          for (const container of containerList) {
            try {
              execSync(`docker rm -f ${container}`, { stdio: 'ignore' });
              this.cleanedItems.push(`Docker container: ${container}`);
            } catch (error) {
              this.log(`Error removing Docker container ${container}: ${error.message}`, 'warning');
            }
          }
        } catch (error) {
          // No containers found, that's fine
        }
        
        spinner.succeed('Docker artifacts cleaned');
        
      } catch (error) {
        spinner.fail('Failed to clean Docker artifacts');
        this.log(`Docker cleanup error: ${error.message}`, 'error');
      }
    }
  }

  async cleanPiGenArtifacts() {
    if (argv.piGen || argv.all) {
      this.log('Cleaning pi-gen artifacts...');
      
      // Clean pi-gen work directory
      const workDir = path.join(config.piGenDir, 'work');
      await this.cleanDirectory(workDir, 'pi-gen work directory');
      
      // Clean pi-gen deploy directory
      const deployDir = path.join(config.piGenDir, 'deploy');
      await this.cleanDirectory(deployDir, 'pi-gen deploy directory');
      
      // Clean pi-gen build artifacts
      const piGenBuildDir = path.join(config.piGenDir, 'build');
      await this.cleanDirectory(piGenBuildDir, 'pi-gen build directory');
    }
  }

  async cleanTempFiles() {
    if (argv.temp || argv.all) {
      await this.cleanDirectory(config.tempDir, 'Temporary files');
      
      // Clean common temp files
      const tempFiles = [
        '*.tmp',
        '*.temp',
        '*.log',
        '*.pid',
        'core',
        'core.*',
        '.DS_Store',
        'Thumbs.db'
      ];
      
      for (const pattern of tempFiles) {
        try {
          const { glob } = require('glob');
          const files = await glob(pattern, { dot: true });
          for (const file of files) {
            await fs.remove(file);
            this.cleanedItems.push(`Temp file: ${file}`);
          }
        } catch (error) {
          // Pattern not found or glob not available
        }
      }
    }
  }

  async cleanLogFiles() {
    if (argv.logs || argv.all) {
      await this.cleanDirectory(config.logsDir, 'Log files');
      
      // Clean log files in current directory
      const logFiles = [
        '*.log',
        '*.out',
        '*.err',
        'debug.log',
        'error.log',
        'access.log'
      ];
      
      for (const pattern of logFiles) {
        try {
          const { glob } = require('glob');
          const files = await glob(pattern);
          for (const file of files) {
            await fs.remove(file);
            this.cleanedItems.push(`Log file: ${file}`);
          }
        } catch (error) {
          // Pattern not found or glob not available
        }
      }
    }
  }

  async cleanCMakeCache() {
    this.log('Cleaning CMake cache...');
    
    const cmakeFiles = [
      'CMakeCache.txt',
      'CMakeFiles',
      'cmake_install.cmake',
      'Makefile',
      'CTestTestfile.cmake'
    ];
    
    for (const file of cmakeFiles) {
      if (await fs.pathExists(file)) {
        try {
          await fs.remove(file);
          this.cleanedItems.push(`CMake file: ${file}`);
        } catch (error) {
          this.log(`Error removing ${file}: ${error.message}`, 'warning');
        }
      }
    }
  }

  async cleanNodeModules() {
    if (await fs.pathExists('node_modules')) {
      const spinner = ora('Cleaning node_modules').start();
      try {
        await fs.remove('node_modules');
        this.cleanedItems.push('node_modules');
        spinner.succeed('node_modules cleaned');
      } catch (error) {
        spinner.fail('Failed to clean node_modules');
        this.log(`Error cleaning node_modules: ${error.message}`, 'error');
      }
    }
  }

  async cleanBuildArtifacts() {
    if (!argv.artifacts && !argv.all) return;
    
    this.log('Cleaning build artifacts...');
    
    // Build artifact patterns to clean
    const patterns = [
      '**/*.o',           // Object files
      '**/*.a',           // Static libraries
      '**/*.so',          // Shared libraries
      '**/*.dylib',       // macOS dynamic libraries
      '**/*.exe',         // Windows executables
      '**/*.dll',         // Windows dynamic libraries
      '**/*.obj',         // Windows object files
      '**/*.lib',         // Windows static libraries
      '**/*.pdb',         // Windows debug files
      '**/*.ilk',         // Windows incremental linker files
      '**/*.exp',         // Windows export files
      '**/*.map',         // Map files
      '**/*.pch',         // Precompiled headers
      '**/*.gch',         // GCC precompiled headers
      '**/*.dSYM',        // macOS debug symbols
      '**/CMakeCache.txt', // CMake cache files
      '**/CMakeFiles',    // CMake files directory
      '**/cmake_install.cmake', // CMake install files
      '**/Makefile',      // Makefiles (except in pi-gen)
      '**/CTestTestfile.cmake', // CTest files
      '**/compile_commands.json', // Compilation database
      '**/install_manifest.txt', // CMake install manifest
      '**/_deps'          // CMake dependencies
    ];

    const { glob } = require('glob');
    
    for (const pattern of patterns) {
      try {
        const files = await glob(pattern, { 
          dot: true,
          ignore: ['pi-gen/**', 'node_modules/**', '.git/**'] // Exclude pi-gen and other directories
        });
        
        for (const file of files) {
          try {
            await fs.remove(file);
            this.cleanedItems.push(`Build artifact: ${file}`);
          } catch (error) {
            this.log(`Error removing ${file}: ${error.message}`, 'warning');
          }
        }
      } catch (error) {
        // Pattern not found or glob error
        this.log(`Pattern ${pattern} not found or error: ${error.message}`, 'debug');
      }
    }

    // Clean specific build directories
    const buildDirs = [
      'build',
      'cmake-build-*',
      'bin',
      'lib',
      'libs',
      'dist',
      'dist-*',
      'coverage',
      '.nyc_output'
    ];

    for (const dirPattern of buildDirs) {
      try {
        const dirs = await glob(dirPattern, { 
          dot: true,
          ignore: ['pi-gen/**', 'node_modules/**', '.git/**']
        });
        
        for (const dir of dirs) {
          if (await fs.pathExists(dir)) {
            try {
              await fs.remove(dir);
              this.cleanedItems.push(`Build directory: ${dir}`);
            } catch (error) {
              this.log(`Error removing directory ${dir}: ${error.message}`, 'warning');
            }
          }
        }
      } catch (error) {
        // Pattern not found or glob error
        this.log(`Build directory pattern ${dirPattern} not found or error: ${error.message}`, 'debug');
      }
    }
  }

  async showCleanSummary() {
    this.log('Clean Summary:', 'info');
    console.log(`  Items cleaned: ${chalk.cyan(this.cleanedItems.length)}`);
    console.log('');
    
    if (this.cleanedItems.length > 0) {
      this.log('Cleaned items:', 'success');
      this.cleanedItems.forEach(item => {
        console.log(`  ${chalk.green('✓')} ${item}`);
      });
    } else {
      this.log('No items to clean', 'info');
    }
    console.log('');
  }

  async confirmClean() {
    if (argv.force) return true;
    
    const inquirer = require('inquirer');
    const { confirm } = await inquirer.prompt([
      {
        type: 'confirm',
        name: 'confirm',
        message: 'Are you sure you want to clean these artifacts?',
        default: false
      }
    ]);
    
    return confirm;
  }

  async clean() {
    try {
      this.log(`Starting ${config.projectName} cleanup...`);
      
      if (!argv.force) {
        const confirmed = await this.confirmClean();
        if (!confirmed) {
          this.log('Clean cancelled', 'info');
          return;
        }
      }
      
      await this.cleanBuildDirectory();
      await this.cleanTestArtifacts();
      await this.cleanDockerArtifacts();
      await this.cleanPiGenArtifacts();
      await this.cleanTempFiles();
      await this.cleanLogFiles();
      await this.cleanCMakeCache();
      await this.cleanBuildArtifacts();
      await this.cleanNodeModules();
      
      await this.showCleanSummary();
      
      this.log('Cleanup completed successfully!', 'success');
      
    } catch (error) {
      this.log(`Cleanup failed: ${error.message}`, 'error');
      process.exit(1);
    }
  }
}

// Main execution
if (require.main === module) {
  const cleaner = new AlpacaPiCleaner();
  cleaner.clean();
}

module.exports = AlpacaPiCleaner;
