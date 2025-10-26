#!/bin/bash
set -e

# Create initramfs with NativeAOT binary
# This script creates a bootable initramfs containing the .NET application

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
NATIVEAOT_DIR="$PROJECT_ROOT/build/nativeaot"
ROOTFS_DIR="$PROJECT_ROOT/build/rootfs"
INITRAMFS_DIR="$PROJECT_ROOT/build/initramfs"

echo "=== Creating initramfs ==="
echo ""

# Ensure the NativeAOT binary exists
if [ ! -f "$NATIVEAOT_DIR/UniKernelApp" ]; then
    echo "Error: NativeAOT binary not found at $NATIVEAOT_DIR/UniKernelApp"
    echo "Please run ./scripts/build-nativeaot.sh first"
    exit 1
fi

# Clean and create rootfs directory
rm -rf "$ROOTFS_DIR"
mkdir -p "$ROOTFS_DIR"

# Create basic directory structure
mkdir -p "$ROOTFS_DIR/bin"
mkdir -p "$ROOTFS_DIR/lib"
mkdir -p "$ROOTFS_DIR/lib64"
mkdir -p "$ROOTFS_DIR/usr/lib"
mkdir -p "$ROOTFS_DIR/dev"
mkdir -p "$ROOTFS_DIR/proc"
mkdir -p "$ROOTFS_DIR/sys"

# Copy the NativeAOT binary as /init (the kernel will execute this first)
echo "Copying NativeAOT binary as /init..."
cp "$NATIVEAOT_DIR/UniKernelApp" "$ROOTFS_DIR/init"
chmod +x "$ROOTFS_DIR/init"

# Check and copy dependencies
echo "Checking dependencies..."
DEPS=$(ldd "$NATIVEAOT_DIR/UniKernelApp" | grep "=>" | awk '{print $3}' | grep -v "^$" || true)

if [ -n "$DEPS" ]; then
    echo "Copying required libraries:"
    for lib in $DEPS; do
        if [ -f "$lib" ]; then
            echo "  - $lib"
            # Determine target directory based on lib path
            if [[ "$lib" == /lib/x86_64-linux-gnu/* ]]; then
                mkdir -p "$ROOTFS_DIR/lib/x86_64-linux-gnu"
                cp "$lib" "$ROOTFS_DIR/lib/x86_64-linux-gnu/"
            elif [[ "$lib" == /lib64/* ]]; then
                cp "$lib" "$ROOTFS_DIR/lib64/"
            elif [[ "$lib" == /lib/* ]]; then
                cp "$lib" "$ROOTFS_DIR/lib/"
            elif [[ "$lib" == /usr/lib/x86_64-linux-gnu/* ]]; then
                mkdir -p "$ROOTFS_DIR/usr/lib/x86_64-linux-gnu"
                cp "$lib" "$ROOTFS_DIR/usr/lib/x86_64-linux-gnu/"
            else
                # Default to /lib
                cp "$lib" "$ROOTFS_DIR/lib/"
            fi
        fi
    done
    
    # Copy the dynamic linker/loader
    LINKER=$(ldd "$NATIVEAOT_DIR/UniKernelApp" | grep "ld-linux" | awk '{print $1}')
    if [ -n "$LINKER" ] && [ -f "$LINKER" ]; then
        echo "  - $LINKER (dynamic linker)"
        cp "$LINKER" "$ROOTFS_DIR/lib64/"
    fi
else
    echo "No dynamic dependencies found (fully static binary)"
fi

echo ""

# Create initramfs
rm -rf "$INITRAMFS_DIR"
mkdir -p "$INITRAMFS_DIR"

echo "Creating initramfs archive..."
cd "$ROOTFS_DIR"
find . -print0 | cpio --null --create --format=newc > "$INITRAMFS_DIR/initramfs.cpio"
gzip -f "$INITRAMFS_DIR/initramfs.cpio"

echo ""
echo "=== initramfs Creation Complete ==="
echo "initramfs location: $INITRAMFS_DIR/initramfs.cpio.gz"
ls -lh "$INITRAMFS_DIR/initramfs.cpio.gz"
echo ""
