#!/bin/bash

# AlpacaPi Performance Diagnostic Script
# This script helps diagnose why your Threadripper might be building slowly

echo "🔍 AlpacaPi Performance Diagnostic"
echo "=================================="

# Get system information
echo "📊 System Information:"
echo "   • CPU Cores: $(nproc)"
echo "   • CPU Model: $(lscpu | grep "Model name" | cut -d: -f2 | xargs)"
echo "   • Total Memory: $(free -h | grep "Mem:" | awk '{print $2}')"
echo "   • Available Memory: $(free -h | grep "Mem:" | awk '{print $7}')"
echo "   • Storage: $(df -h / | tail -1 | awk '{print $2 " total, " $4 " available"}')"

# Check if running in VM or container
echo ""
echo "🐳 Environment Check:"
if [ -f /.dockerenv ]; then
    echo "   • Running in Docker container"
elif [ -n "$VIRTUAL_ENV" ]; then
    echo "   • Running in virtual environment"
elif systemd-detect-virt >/dev/null 2>&1; then
    echo "   • Running in: $(systemd-detect-virt)"
else
    echo "   • Running on bare metal"
fi

# Check CPU frequency scaling
echo ""
echo "⚡ CPU Performance:"
if command -v cpufreq-info >/dev/null 2>&1; then
    echo "   • CPU Frequency Scaling:"
    cpufreq-info | grep "current CPU frequency" | head -4
else
    echo "   • CPU Frequency: $(lscpu | grep "CPU MHz" | cut -d: -f2 | xargs) MHz"
fi

# Check if all cores are being used
echo ""
echo "🔥 Parallel Processing Check:"
echo "   • MAKEFLAGS: ${MAKEFLAGS:-Not set}"
echo "   • MAKEOPTS: ${MAKEFLAGS:-Not set}"
echo "   • PARALLEL_JOBS: ${PARALLEL_JOBS:-Not set}"

# Check Docker configuration
echo ""
echo "🐳 Docker Configuration:"
if command -v docker >/dev/null 2>&1; then
    echo "   • Docker version: $(docker --version)"
    echo "   • Docker BuildKit: ${DOCKER_BUILDKIT:-Not set}"
    echo "   • Docker daemon status: $(systemctl is-active docker)"

    # Check Docker daemon configuration
    if [ -f /etc/docker/daemon.json ]; then
        echo "   • Docker daemon config exists"
        echo "   • Max concurrent downloads: $(grep -o '"max-concurrent-downloads": [0-9]*' /etc/docker/daemon.json | cut -d: -f2 | tr -d ' ' || echo 'Not set')"
    else
        echo "   • Docker daemon config: Not found"
    fi
else
    echo "   • Docker: Not installed"
fi

# Check ccache
echo ""
echo "💾 Build Cache:"
if command -v ccache >/dev/null 2>&1; then
    echo "   • ccache version: $(ccache --version | head -1)"
    echo "   • ccache cache size: $(ccache -s | grep "cache size" | cut -d: -f2 | xargs)"
    echo "   • ccache hit rate: $(ccache -s | grep "hit rate" | cut -d: -f2 | xargs)"
else
    echo "   • ccache: Not installed"
fi

# Check system load
echo ""
echo "📈 System Load:"
echo "   • Load average: $(uptime | awk -F'load average:' '{print $2}')"
echo "   • Running processes: $(ps aux | wc -l)"
echo "   • Memory usage: $(free | grep "Mem:" | awk '{printf "%.1f%%", $3/$2 * 100.0}')"

# Check for potential bottlenecks
echo ""
echo "⚠️  Potential Issues:"
if [ $(nproc) -ge 16 ] && [ -z "$MAKEFLAGS" ]; then
    echo "   • HIGH-CORE SYSTEM: Environment variables not set for parallel processing!"
    echo "     Run: ./optimize-build.sh"
fi

if [ -f /.dockerenv ]; then
    echo "   • DOCKER: Building inside container may be slower than native"
fi

if [ $(free | grep "Mem:" | awk '{print $7}') -lt 2000000 ]; then
    echo "   • LOW MEMORY: Less than 2GB available memory may slow builds"
fi

if [ $(df / | tail -1 | awk '{print $4}' | sed 's/G//') -lt 10 ]; then
    echo "   • LOW DISK SPACE: Less than 10GB free space may slow builds"
fi

# Recommendations
echo ""
echo "💡 Recommendations for Threadripper:"
if [ $(nproc) -ge 16 ]; then
    echo "   1. Run: ./optimize-build.sh (if not already done)"
    echo "   2. Ensure you're not running in a VM or container"
    echo "   3. Check CPU frequency scaling is set to 'performance'"
    echo "   4. Ensure adequate cooling for sustained high CPU usage"
    echo "   5. Use fast SSD storage for build directory"
    echo "   6. Close unnecessary applications during build"
fi

echo ""
echo "🚀 Expected Build Times for Threadripper:"
echo "   • 16-core Threadripper: 15-25 minutes"
echo "   • 24-core Threadripper: 10-20 minutes"
echo "   • 32-core Threadripper: 8-15 minutes"
echo ""
echo "If your build is taking longer than expected, check the issues above."
