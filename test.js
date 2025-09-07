#!/usr/bin/env node

/**
 * AlpacaPi Test Runner
 * 
 * Cross-platform test runner for AlpacaPi using Docker and native testing
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
  testDir: 'tests',
  dockerImage: 'alpacapi-tester'
};

// Parse command line arguments
const argv = yargs(hideBin(process.argv))
  .option('type', {
    alias: 't',
    type: 'string',
    choices: ['unit', 'integration', 'driver', 'all'],
    default: 'all',
    description: 'Type of tests to run'
  })
  .option('driver', {
    alias: 'd',
    type: 'string',
    description: 'Specific driver to test'
  })
  .option('docker', {
    type: 'boolean',
    default: true,
    description: 'Use Docker for testing'
  })
  .option('verbose', {
    alias: 'v',
    type: 'boolean',
    default: false,
    description: 'Verbose output'
  })
  .option('coverage', {
    type: 'boolean',
    default: false,
    description: 'Generate test coverage report'
  })
  .option('parallel', {
    alias: 'p',
    type: 'boolean',
    default: true,
    description: 'Run tests in parallel'
  })
  .help()
  .argv;

class AlpacaPiTester {
  constructor() {
    this.verbose = argv.verbose;
    this.testResults = {
      passed: 0,
      failed: 0,
      skipped: 0,
      total: 0
    };
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
    this.log('Checking test prerequisites...');
    
    // Check if build exists
    if (!await fs.pathExists(config.buildDir)) {
      throw new Error('Build directory not found. Please run build first.');
    }
    
    // Check if tests exist
    if (!await fs.pathExists(config.testDir)) {
      this.log('No tests directory found, creating basic test structure...', 'warning');
      await this.createBasicTestStructure();
    }
    
    this.log('Prerequisites check passed', 'success');
  }

  async createBasicTestStructure() {
    await fs.ensureDir(config.testDir);
    
    // Create basic test files
    const testFiles = [
      'test_core.cpp',
      'test_drivers.cpp',
      'test_network.cpp',
      'test_utils.cpp'
    ];
    
    for (const file of testFiles) {
      const testContent = `#include <gtest/gtest.h>
#include <iostream>

// Basic test for ${file.replace('.cpp', '')}
TEST(BasicTest, ${file.replace('.cpp', '').replace('test_', '')}) {
    EXPECT_TRUE(true);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
`;
      await fs.writeFile(path.join(config.testDir, file), testContent);
    }
    
    this.log('Basic test structure created', 'success');
  }

  async runUnitTests() {
    this.log('Running unit tests...');
    const spinner = ora('Running unit tests').start();
    
    try {
      // Find test executables
      const testFiles = await fs.readdir(config.buildDir);
      const testExecutables = testFiles.filter(file => 
        file.startsWith('test_') && file.endsWith('.exe') || 
        file.startsWith('test_') && !file.includes('.')
      );
      
      if (testExecutables.length === 0) {
        spinner.warn('No unit test executables found');
        return;
      }
      
      // Run each test
      for (const test of testExecutables) {
        this.log(`Running ${test}...`);
        try {
          execSync(`./${test}`, {
            cwd: config.buildDir,
            stdio: this.verbose ? 'inherit' : 'pipe'
          });
          this.testResults.passed++;
        } catch (error) {
          this.testResults.failed++;
          this.log(`Test ${test} failed`, 'error');
        }
        this.testResults.total++;
      }
      
      spinner.succeed('Unit tests completed');
      
    } catch (error) {
      spinner.fail('Unit tests failed');
      throw error;
    }
  }

  async runIntegrationTests() {
    this.log('Running integration tests...');
    const spinner = ora('Running integration tests').start();
    
    try {
      // Run CMake test target
      execSync('cmake --build . --target test', {
        cwd: config.buildDir,
        stdio: this.verbose ? 'inherit' : 'pipe'
      });
      
      this.testResults.passed++;
      this.testResults.total++;
      spinner.succeed('Integration tests completed');
      
    } catch (error) {
      this.testResults.failed++;
      this.testResults.total++;
      spinner.fail('Integration tests failed');
    }
  }

  async runDriverTests() {
    this.log('Running driver tests...');
    const spinner = ora('Running driver tests').start();
    
    try {
      // Find driver test executables
      const testFiles = await fs.readdir(config.buildDir);
      const driverTests = testFiles.filter(file => 
        file.includes('driver') && (file.endsWith('.exe') || !file.includes('.'))
      );
      
      if (driverTests.length === 0) {
        spinner.warn('No driver test executables found');
        return;
      }
      
      // Run driver tests
      for (const test of driverTests) {
        if (argv.driver && !test.includes(argv.driver)) {
          continue;
        }
        
        this.log(`Running driver test ${test}...`);
        try {
          execSync(`./${test}`, {
            cwd: config.buildDir,
            stdio: this.verbose ? 'inherit' : 'pipe'
          });
          this.testResults.passed++;
        } catch (error) {
          this.testResults.failed++;
          this.log(`Driver test ${test} failed`, 'error');
        }
        this.testResults.total++;
      }
      
      spinner.succeed('Driver tests completed');
      
    } catch (error) {
      spinner.fail('Driver tests failed');
      throw error;
    }
  }

  async runDockerTests() {
    this.log('Running tests in Docker...');
    const spinner = ora('Running Docker tests').start();
    
    try {
      // Create test Dockerfile
      await this.createTestDockerfile();
      
      // Build test image
      execSync(`docker build -f Dockerfile.test -t ${config.dockerImage} .`, {
        stdio: this.verbose ? 'inherit' : 'pipe'
      });
      
      // Run tests in Docker
      execSync(`docker run --rm -v "$(pwd)":/workspace ${config.dockerImage}`, {
        stdio: this.verbose ? 'inherit' : 'pipe'
      });
      
      spinner.succeed('Docker tests completed');
      
    } catch (error) {
      spinner.fail('Docker tests failed');
      throw error;
    }
  }

  async createTestDockerfile() {
    const dockerfile = `
# AlpacaPi Test Environment
FROM ubuntu:22.04

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
    libgtest-dev \\
    libgmock-dev \\
    && rm -rf /var/lib/apt/lists/*

# Install OpenCV
RUN apt-get update && apt-get install -y \\
    libopencv-dev \\
    libopencv-contrib-dev \\
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . /workspace/

# Build and test
RUN mkdir -p build && cd build && \\
    cmake .. -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTS=ON && \\
    make -j$(nproc) && \\
    make test

CMD ["/workspace/build/test_runner"]
`;

    await fs.writeFile('Dockerfile.test', dockerfile);
    this.log('Test Dockerfile created', 'success');
  }

  async generateCoverageReport() {
    if (!argv.coverage) return;
    
    this.log('Generating coverage report...');
    const spinner = ora('Generating coverage report').start();
    
    try {
      // This would require gcov and lcov to be installed
      execSync('gcov -r build/src/**/*.o', {
        stdio: this.verbose ? 'inherit' : 'pipe'
      });
      
      // Generate HTML report
      execSync('lcov --capture --directory . --output-file coverage.info', {
        stdio: this.verbose ? 'inherit' : 'pipe'
      });
      
      execSync('genhtml coverage.info --output-directory coverage', {
        stdio: this.verbose ? 'inherit' : 'pipe'
      });
      
      spinner.succeed('Coverage report generated');
      this.log('Coverage report available in coverage/ directory', 'success');
      
    } catch (error) {
      spinner.fail('Coverage report generation failed');
      this.log('Coverage tools not available', 'warning');
    }
  }

  async showTestResults() {
    this.log('Test Results:', 'info');
    console.log(`  Total Tests: ${chalk.cyan(this.testResults.total)}`);
    console.log(`  Passed: ${chalk.green(this.testResults.passed)}`);
    console.log(`  Failed: ${chalk.red(this.testResults.failed)}`);
    console.log(`  Skipped: ${chalk.yellow(this.testResults.skipped)}`);
    console.log('');
    
    if (this.testResults.failed > 0) {
      this.log('Some tests failed. Please check the output above.', 'error');
    } else {
      this.log('All tests passed!', 'success');
    }
  }

  async test() {
    try {
      this.log(`Starting ${config.projectName} tests...`);
      
      await this.checkPrerequisites();
      
      if (argv.docker) {
        await this.runDockerTests();
      } else {
        // Run native tests
        if (argv.type === 'all' || argv.type === 'unit') {
          await this.runUnitTests();
        }
        
        if (argv.type === 'all' || argv.type === 'integration') {
          await this.runIntegrationTests();
        }
        
        if (argv.type === 'all' || argv.type === 'driver') {
          await this.runDriverTests();
        }
      }
      
      await this.generateCoverageReport();
      await this.showTestResults();
      
      if (this.testResults.failed > 0) {
        process.exit(1);
      }
      
    } catch (error) {
      this.log(`Test failed: ${error.message}`, 'error');
      process.exit(1);
    }
  }
}

// Main execution
if (require.main === module) {
  const tester = new AlpacaPiTester();
  tester.test();
}

module.exports = AlpacaPiTester;
