#!/bin/bash
set -e

# Boot the unikernel in QEMU
# This script launches QEMU with the Linux kernel and initramfs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
KERNEL_PATH="$PROJECT_ROOT/build/kernel/bzImage"
INITRAMFS_PATH="$PROJECT_ROOT/build/initramfs/initramfs.cpio.gz"

echo "=== Booting Unikernel in QEMU ==="
echo ""

# Check if kernel exists
if [ ! -f "$KERNEL_PATH" ]; then
    echo "Error: Kernel not found at $KERNEL_PATH"
    echo "Please run ./scripts/get-kernel.sh first"
    exit 1
fi

# Check if initramfs exists
if [ ! -f "$INITRAMFS_PATH" ]; then
    echo "Error: initramfs not found at $INITRAMFS_PATH"
    echo "Please run ./scripts/create-initramfs.sh first"
    exit 1
fi

# Check if QEMU is installed
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo "Error: qemu-system-x86_64 not found"
    echo ""
    echo "Please install QEMU:"
    echo "  Ubuntu/Debian: sudo apt-get install qemu-system-x86"
    echo "  Fedora/RHEL:   sudo dnf install qemu-system-x86"
    echo "  Arch:          sudo pacman -S qemu-system-x86"
    echo "  macOS:         brew install qemu"
    exit 1
fi

echo "Kernel:    $KERNEL_PATH"
echo "initramfs: $INITRAMFS_PATH"
echo ""
echo "Starting QEMU..."
echo "Note: Use Ctrl+A, X to exit QEMU"
echo ""
echo "==================================="
echo ""

# Boot QEMU with the kernel and initramfs
# -nographic: No graphical window, use serial console
# -kernel: Path to Linux kernel
# -initrd: Path to initramfs
# -append: Kernel command line parameters
#   console=ttyS0: Use serial console
#   rdinit=/init: Run /init from initramfs as the first process
qemu-system-x86_64 \
    -kernel "$KERNEL_PATH" \
    -initrd "$INITRAMFS_PATH" \
    -append "console=ttyS0 rdinit=/init" \
    -nographic \
    -m 512M \
    -smp 2

echo ""
echo "=== QEMU Session Ended ==="
