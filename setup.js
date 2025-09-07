#!/usr/bin/env node

/**
 * AlpacaPi Setup Script
 * 
 * Cross-platform setup script for AlpacaPi development environment
 */

const { execSync, spawn } = require('child_process');
const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');
const ora = require('ora');
const inquirer = require('inquirer');
const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');

// Configuration
const config = {
  projectName: 'AlpacaPi',
  nodeVersion: '14.0.0',
  npmVersion: '6.0.0'
};

// Parse command line arguments
const argv = yargs(hideBin(process.argv))
  .option('platform', {
    alias: 'p',
    type: 'string',
    choices: ['linux', 'windows', 'macos', 'pi', 'auto'],
    default: 'auto',
    description: 'Target platform'
  })
  .option('docker', {
    type: 'boolean',
    default: true,
    description: 'Install Docker support'
  })
  .option('pi-gen', {
    type: 'boolean',
    default: false,
    description: 'Setup pi-gen for custom RPi images'
  })
  .option('dev', {
    type: 'boolean',
    default: false,
    description: 'Setup development environment'
  })
  .option('verbose', {
    alias: 'v',
    type: 'boolean',
    default: false,
    description: 'Verbose output'
  })
  .help()
  .argv;

class AlpacaPiSetup {
  constructor() {
    this.platform = this.detectPlatform();
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

  detectPlatform() {
    if (argv.platform !== 'auto') {
      return argv.platform;
    }

    const platform = process.platform;
    switch (platform) {
      case 'win32':
        return 'windows';
      case 'darwin':
        return 'macos';
      case 'linux':
        // Check if it's Raspberry Pi
        try {
          const cpuinfo = fs.readFileSync('/proc/cpuinfo', 'utf8');
          if (cpuinfo.includes('Raspberry Pi')) {
            return 'pi';
          }
        } catch (error) {
          // Not a Linux system or can't read cpuinfo
        }
        return 'linux';
      default:
        return 'linux';
    }
  }

  async checkPrerequisites() {
    this.log('Checking prerequisites...');
    
    // Check Node.js
    try {
      const nodeVersion = process.version;
      const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);
      if (majorVersion < 14) {
        throw new Error(`Node.js 14+ required, found ${nodeVersion}`);
      }
      this.log(`Node.js version: ${nodeVersion}`, 'success');
    } catch (error) {
      this.log(`Node.js check failed: ${error.message}`, 'error');
      throw error;
    }

    // Check npm
    try {
      const npmVersion = execSync('npm --version', { encoding: 'utf8' }).trim();
      this.log(`npm version: ${npmVersion}`, 'success');
    } catch (error) {
      this.log('npm not found', 'error');
      throw error;
    }

    // Check Git
    try {
      const gitVersion = execSync('git --version', { encoding: 'utf8' }).trim();
      this.log(`Git version: ${gitVersion}`, 'success');
    } catch (error) {
      this.log('Git not found', 'error');
      throw error;
    }

    // Check Docker (if requested)
    if (argv.docker) {
      try {
        const dockerVersion = execSync('docker --version', { encoding: 'utf8' });
        this.log(`Docker version: ${dockerVersion.trim()}`, 'success');
      } catch (error) {
        this.log('Docker not found. Please install Docker first.', 'warning');
        this.log('Visit: https://docs.docker.com/get-docker/', 'info');
      }
    }
  }

  async installDependencies() {
    this.log('Installing Node.js dependencies...');
    const spinner = ora('Installing dependencies').start();
    
    try {
      execSync('npm install', {
        stdio: this.verbose ? 'inherit' : 'pipe'
      });
      spinner.succeed('Dependencies installed successfully');
    } catch (error) {
      spinner.fail('Failed to install dependencies');
      throw error;
    }
  }

  async setupPiGen() {
    if (!argv.piGen) return;

    this.log('Setting up pi-gen...');
    const spinner = ora('Setting up pi-gen').start();
    
    try {
      // Check if pi-gen directory exists
      if (!await fs.pathExists('pi-gen/setup-pi-gen.sh')) {
        throw new Error('pi-gen not found. Please ensure pi-gen directory exists.');
      }

      // Run pi-gen setup
      execSync('cd pi-gen && ./setup-pi-gen.sh', {
        stdio: this.verbose ? 'inherit' : 'pipe'
      });

      spinner.succeed('pi-gen setup completed');
    } catch (error) {
      spinner.fail('pi-gen setup failed');
      throw error;
    }
  }

  async setupDevelopmentEnvironment() {
    if (!argv.dev) return;

    this.log('Setting up development environment...');
    
    // Create development directories
    await fs.ensureDir('logs');
    await fs.ensureDir('temp');
    await fs.ensureDir('build');
    
    // Create development configuration
    const devConfig = {
      platform: this.platform,
      docker: argv.docker,
      piGen: argv.piGen,
      verbose: argv.verbose,
      buildType: 'debug',
      target: 'linux'
    };
    
    await fs.writeJson('dev-config.json', devConfig, { spaces: 2 });
    this.log('Development configuration created', 'success');
  }

  async createGitHooks() {
    this.log('Setting up Git hooks...');
    
    const preCommitHook = `#!/bin/bash
# AlpacaPi Pre-commit Hook

echo "Running pre-commit checks..."

# Check for build errors
if ! npm run build > /dev/null 2>&1; then
    echo "Build failed. Please fix errors before committing."
    exit 1
fi

# Check for linting errors
if ! npm run lint > /dev/null 2>&1; then
    echo "Linting failed. Please fix errors before committing."
    exit 1
fi

echo "Pre-commit checks passed."
`;

    await fs.writeFile('.git/hooks/pre-commit', preCommitHook);
    await fs.chmod('.git/hooks/pre-commit', '755');
    this.log('Git hooks configured', 'success');
  }

  async createVSCodeConfig() {
    this.log('Creating VS Code configuration...');
    
    const vscodeDir = '.vscode';
    await fs.ensureDir(vscodeDir);
    
    // Create launch configuration
    const launchConfig = {
      version: '0.2.0',
      configurations: [
        {
          name: 'Debug AlpacaPi',
          type: 'cppdbg',
          request: 'launch',
          program: '${workspaceFolder}/build/alpacapi',
          args: [],
          stopAtEntry: false,
          cwd: '${workspaceFolder}',
          environment: [],
          externalConsole: false,
          MIMode: 'gdb',
          setupCommands: [
            {
              description: 'Enable pretty-printing for gdb',
              text: '-enable-pretty-printing',
              ignoreFailures: true
            }
          ]
        }
      ]
    };
    
    await fs.writeJson(path.join(vscodeDir, 'launch.json'), launchConfig, { spaces: 2 });
    
    // Create tasks configuration
    const tasksConfig = {
      version: '2.0.0',
      tasks: [
        {
          label: 'Build AlpacaPi',
          type: 'shell',
          command: 'npm run build',
          group: 'build',
          presentation: {
            echo: true,
            reveal: 'always',
            focus: false,
            panel: 'shared'
          }
        },
        {
          label: 'Test AlpacaPi',
          type: 'shell',
          command: 'npm run test',
          group: 'test',
          presentation: {
            echo: true,
            reveal: 'always',
            focus: false,
            panel: 'shared'
          }
        }
      ]
    };
    
    await fs.writeJson(path.join(vscodeDir, 'tasks.json'), tasksConfig, { spaces: 2 });
    this.log('VS Code configuration created', 'success');
  }

  async showSetupSummary() {
    this.log('Setup Summary:', 'info');
    console.log(`  Platform: ${chalk.cyan(this.platform)}`);
    console.log(`  Docker Support: ${chalk.cyan(argv.docker)}`);
    console.log(`  Pi-Gen Setup: ${chalk.cyan(argv.piGen)}`);
    console.log(`  Development Mode: ${chalk.cyan(argv.dev)}`);
    console.log(`  Verbose: ${chalk.cyan(argv.verbose)}`);
    console.log('');
    
    this.log('Next Steps:', 'info');
    console.log('  1. Run tests: npm run test');
    console.log('  2. Build project: npm run build');
    console.log('  3. Build RPi image: npm run build:pi-gen');
    console.log('  4. Start development: npm run dev');
    console.log('');
  }

  async setup() {
    try {
      this.log(`Setting up ${config.projectName}...`);
      
      await this.checkPrerequisites();
      await this.installDependencies();
      await this.setupPiGen();
      await this.setupDevelopmentEnvironment();
      await this.createGitHooks();
      await this.createVSCodeConfig();
      
      await this.showSetupSummary();
      
      this.log('Setup completed successfully!', 'success');
      
    } catch (error) {
      this.log(`Setup failed: ${error.message}`, 'error');
      process.exit(1);
    }
  }
}

// Main execution
if (require.main === module) {
  const setup = new AlpacaPiSetup();
  setup.setup();
}

module.exports = AlpacaPiSetup;
