#!/bin/bash
set -e

# Master build script - builds everything needed for the unikernel
# This script runs all build steps in sequence

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "  NativeAOT Unikernel Build Script"
echo "========================================"
echo ""

# Step 1: Build NativeAOT binary
echo "Step 1: Building NativeAOT binary..."
bash "$SCRIPT_DIR/build-nativeaot.sh"
echo ""

# Step 2: Create initramfs
echo "Step 2: Creating initramfs..."
bash "$SCRIPT_DIR/create-initramfs.sh"
echo ""

# Step 3: Get kernel (if needed)
echo "Step 3: Checking for kernel..."
bash "$SCRIPT_DIR/get-kernel.sh"
echo ""

echo "========================================"
echo "  Build Complete!"
echo "========================================"
echo ""
echo "To boot the unikernel, run:"
echo "  ./scripts/boot-qemu.sh"
echo ""
echo "Or to test without QEMU, you can run the binary directly:"
echo "  ./build/nativeaot/UniKernelApp"
echo ""
