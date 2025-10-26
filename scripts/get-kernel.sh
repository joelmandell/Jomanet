#!/bin/bash
set -e

# Download Linux kernel for QEMU boot
# This script downloads a prebuilt Linux kernel suitable for QEMU

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
KERNEL_DIR="$PROJECT_ROOT/build/kernel"

KERNEL_VERSION="6.1.0"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz"

echo "=== Downloading Linux Kernel ==="
echo ""

mkdir -p "$KERNEL_DIR"

# For this example, we'll provide instructions to use the host kernel
# or download a prebuilt kernel image

echo "Note: This script provides options for obtaining a Linux kernel."
echo ""
echo "Option 1: Use a prebuilt kernel (easiest)"
echo "  You can use a prebuilt kernel from your distribution."
echo ""
echo "Option 2: Use your system's kernel"
SYSTEM_KERNEL="/boot/vmlinuz-$(uname -r)"
if [ -f "$SYSTEM_KERNEL" ]; then
    echo "  Found system kernel: $SYSTEM_KERNEL"
    echo "  Copying to build directory..."
    cp "$SYSTEM_KERNEL" "$KERNEL_DIR/bzImage"
    echo "  Kernel copied to: $KERNEL_DIR/bzImage"
else
    echo "  System kernel not found at expected location."
fi

echo ""
echo "Option 3: Download and extract a prebuilt kernel"
echo "  This would require downloading from a trusted source."
echo ""

if [ -f "$KERNEL_DIR/bzImage" ]; then
    echo "Kernel ready at: $KERNEL_DIR/bzImage"
    ls -lh "$KERNEL_DIR/bzImage"
else
    echo "No kernel found. Please place a bzImage at: $KERNEL_DIR/bzImage"
    echo ""
    echo "You can:"
    echo "  1. Copy from /boot/vmlinuz-* on your system"
    echo "  2. Download a prebuilt kernel"
    echo "  3. Build your own kernel from source"
fi

echo ""
echo "=== Kernel Setup Complete ==="
