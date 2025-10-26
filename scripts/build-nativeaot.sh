#!/bin/bash
set -e

# Build script for NativeAOT binary
# This script builds the C# application into a native Linux binary using NativeAOT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$PROJECT_ROOT/src/UniKernelApp"
OUTPUT_DIR="$PROJECT_ROOT/build/nativeaot"

echo "=== Building NativeAOT Binary ==="
echo "Project: $PROJECT_DIR"
echo "Output: $OUTPUT_DIR"
echo ""

# Clean previous build
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Build the NativeAOT binary
echo "Building NativeAOT binary..."
cd "$PROJECT_DIR"
dotnet publish \
    -c Release \
    -r linux-x64 \
    -p:PublishAot=true \
    --self-contained true \
    -o "$OUTPUT_DIR"

echo ""
echo "Build complete!"
echo "Binary location: $OUTPUT_DIR/UniKernelApp"
echo ""

# Check dependencies
echo "Checking binary dependencies:"
ldd "$OUTPUT_DIR/UniKernelApp" || true
echo ""

# Get binary info
echo "Binary information:"
file "$OUTPUT_DIR/UniKernelApp"
ls -lh "$OUTPUT_DIR/UniKernelApp"
echo ""

echo "=== Build Complete ==="
