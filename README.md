# Jomanet - NativeAOT Unikernel Example

A demonstration of creating a "unikernel-like" environment by booting the Linux kernel with an initramfs that contains a single NativeAOT .NET 9 binary.

## What is This?

This project creates a minimal bootable system where:
- The Linux kernel boots with a custom initramfs
- The initramfs contains a single .NET application compiled with NativeAOT
- The .NET application runs as the init process (PID 1)
- No traditional userland utilities are needed

This approach provides:
- **Fast iteration**: Test changes quickly in QEMU
- **Realistic environment**: Real Linux kernel, no emulation
- **True single-binary OS**: Just the kernel and your .NET app
- **No EFI complexity**: Uses standard kernel boot process

## Prerequisites

- .NET 9 SDK or later
- Linux operating system (for building)
- Basic build tools: `cpio`, `gzip` (usually pre-installed)
- QEMU (for testing): `qemu-system-x86_64`

### Installing QEMU

**Ubuntu/Debian:**
```bash
sudo apt-get install qemu-system-x86
```

**Fedora/RHEL:**
```bash
sudo dnf install qemu-system-x86
```

**Arch Linux:**
```bash
sudo pacman -S qemu-system-x86
```

**macOS:**
```bash
brew install qemu
```

## Quick Start

Build everything with one command:

```bash
./scripts/build-all.sh
```

This will:
1. Build the NativeAOT binary
2. Create the initramfs
3. Set up the kernel (if available)

Then boot in QEMU:

```bash
./scripts/boot-qemu.sh
```

**Note:** Use `Ctrl+A`, then `X` to exit QEMU.

## Manual Build Steps

If you prefer to run each step individually:

### 1. Build the NativeAOT Binary

```bash
./scripts/build-nativeaot.sh
```

This compiles the C# application into a native Linux binary optimized for size.

### 2. Create the initramfs

```bash
./scripts/create-initramfs.sh
```

This creates a bootable initramfs archive containing:
- Your NativeAOT binary as `/init`
- Any required shared libraries
- Basic directory structure

### 3. Get a Kernel

```bash
./scripts/get-kernel.sh
```

This attempts to copy your system kernel to the build directory. Alternatively, you can manually place a `bzImage` at `build/kernel/bzImage`.

### 4. Boot in QEMU

```bash
./scripts/boot-qemu.sh
```

This launches QEMU with your kernel and initramfs.

## Testing the Binary Directly

You can test the NativeAOT binary directly without QEMU:

```bash
./build/nativeaot/UniKernelApp
```

This runs it as a regular application on your system.

## Project Structure

```
.
├── src/
│   └── UniKernelApp/          # C# NativeAOT application
│       ├── Program.cs         # Main application code
│       └── UniKernelApp.csproj # Project configuration
├── scripts/
│   ├── build-all.sh           # Master build script
│   ├── build-nativeaot.sh     # Build NativeAOT binary
│   ├── create-initramfs.sh    # Create initramfs archive
│   ├── get-kernel.sh          # Obtain Linux kernel
│   └── boot-qemu.sh           # Boot in QEMU
├── build/                     # Build outputs (generated)
│   ├── nativeaot/            # NativeAOT binary
│   ├── rootfs/               # initramfs root filesystem
│   ├── initramfs/            # Final initramfs archive
│   └── kernel/               # Linux kernel image
└── README.md
```

## How It Works

### NativeAOT Compilation

The C# application is compiled using .NET's NativeAOT feature, which produces a native binary that:
- Contains no .NET runtime (ahead-of-time compiled)
- Has minimal dependencies
- Starts instantly
- Is optimized for size

Configuration in `UniKernelApp.csproj`:
- `PublishAot=true`: Enable NativeAOT compilation
- `InvariantGlobalization=true`: Reduce size by removing globalization data
- `StripSymbols=true`: Remove debug symbols
- `IlcOptimizationPreference=Size`: Optimize for smaller binary size

### initramfs Structure

The initramfs is a compressed CPIO archive containing:
- `/init`: Your NativeAOT binary (kernel executes this first)
- `/lib`, `/lib64`: Shared libraries (if needed)
- `/dev`, `/proc`, `/sys`: Standard directories for kernel interfaces

The Linux kernel unpacks this archive into a RAM filesystem and executes `/init` as PID 1.

### Kernel Boot Process

1. QEMU loads the Linux kernel (`bzImage`)
2. Kernel decompresses and loads the initramfs
3. Kernel mounts the initramfs as the root filesystem
4. Kernel executes `/init` (your .NET application)
5. Your application runs with full system access

Kernel parameters used:
- `console=ttyS0`: Direct output to serial console (visible in QEMU)
- `rdinit=/init`: Use `/init` from initramfs as the init process

## Customizing the Application

Edit `src/UniKernelApp/Program.cs` to add your own functionality. The application runs with full system privileges and can:
- Access hardware through Linux APIs
- Create network services
- Perform system-level tasks
- Interact with kernel subsystems

After making changes, rebuild:

```bash
./scripts/build-all.sh
./scripts/boot-qemu.sh
```

## Troubleshooting

### Build Errors

**Error: NativeAOT compilation fails**
- Ensure you have .NET 9 SDK installed: `dotnet --version`
- Make sure you're on a supported platform (Linux x64)

**Error: ldd shows missing libraries**
- The `create-initramfs.sh` script automatically copies dependencies
- For fully static builds, consider using musl instead of glibc

### Runtime Errors

**QEMU doesn't start**
- Install QEMU: See prerequisites section
- Verify kernel exists: `ls -lh build/kernel/bzImage`

**Binary crashes in QEMU**
- Test the binary directly first: `./build/nativeaot/UniKernelApp`
- Check dependencies: `ldd build/nativeaot/UniKernelApp`
- Verify libraries were copied: `ls -R build/rootfs/lib`

### Kernel Issues

**No kernel found**
- Run `./scripts/get-kernel.sh` to copy system kernel
- Or manually copy a kernel: `cp /boot/vmlinuz-$(uname -r) build/kernel/bzImage`

## UEFI Alternative

The current implementation uses the Linux kernel for simplicity. For a true firmware-level unikernel without Linux, you would need to:

1. Create an EFI application from NativeAOT code
2. Configure NativeAOT to target `efi-x64`
3. Boot directly from UEFI firmware

This is more complex but eliminates the Linux kernel dependency. The initramfs approach is recommended for prototyping and development.

## Performance Characteristics

- **Boot time**: Seconds (depending on kernel and QEMU)
- **Memory usage**: Minimal (your app + kernel)
- **Binary size**: Typically 2-10 MB for NativeAOT
- **Startup time**: Near-instant (no JIT compilation)

## Use Cases

- Embedded systems requiring .NET
- Microservices with minimal footprint
- Learning OS concepts with C#
- Testing kernel interfaces from .NET
- Rapid prototyping of system software

## License

See LICENSE file for details.

## References

- [.NET NativeAOT Documentation](https://learn.microsoft.com/en-us/dotnet/core/deploying/native-aot/)
- [Linux initramfs Documentation](https://www.kernel.org/doc/html/latest/filesystems/ramfs-rootfs-initramfs.html)
- [QEMU Documentation](https://www.qemu.org/documentation/)