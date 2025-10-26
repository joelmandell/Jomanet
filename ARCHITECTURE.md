# Architecture and Design

## Overview

This project demonstrates how to create a minimal "unikernel-like" system using .NET NativeAOT and Linux. Unlike traditional operating systems with many processes and services, this approach runs a single .NET application as the init process.

## Architecture Diagram

```
┌─────────────────────────────────────────┐
│           QEMU Virtual Machine          │
│                                         │
│  ┌────────────────────────────────────┐ │
│  │       Linux Kernel (bzImage)       │ │
│  │                                    │ │
│  │  - Memory Management               │ │
│  │  - Process Scheduling              │ │
│  │  - Device Drivers                  │ │
│  │  - Network Stack                   │ │
│  │  - Filesystem Support              │ │
│  └────────────────────────────────────┘ │
│                  ↓                      │
│  ┌────────────────────────────────────┐ │
│  │      initramfs (RAM filesystem)    │ │
│  │                                    │ │
│  │  /init → Your .NET Application     │ │
│  │  /lib  → Shared Libraries          │ │
│  │  /lib64 → Dynamic Linker           │ │
│  │  /dev, /proc, /sys → Kernel APIs   │ │
│  └────────────────────────────────────┘ │
│                  ↓                      │
│  ┌────────────────────────────────────┐ │
│  │   NativeAOT .NET Application       │ │
│  │           (PID 1)                  │ │
│  │                                    │ │
│  │  - Your C# Code                    │ │
│  │  - Compiled to Native Code         │ │
│  │  - Full System Access              │ │
│  │  - Minimal Dependencies            │ │
│  └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## Boot Process

### 1. QEMU Startup
- QEMU loads the Linux kernel (`bzImage`) into memory
- QEMU loads the initramfs (`initramfs.cpio.gz`) into memory
- QEMU transfers control to the kernel

### 2. Kernel Initialization
- Kernel decompresses itself
- Initializes hardware and subsystems
- Mounts the initramfs as the root filesystem (RAM-based)
- Looks for `/init` in the initramfs

### 3. Init Process Launch
- Kernel executes `/init` (your NativeAOT binary)
- This becomes PID 1 (the init process)
- Your application now has full system control

### 4. Application Execution
- Your .NET code runs with full privileges
- Can access all kernel APIs
- Has complete control over the system

## Components

### Linux Kernel
- Provides hardware abstraction
- Manages memory and processes
- Offers system calls to user space
- Handles device drivers and networking

**Why use a kernel?**
- Battle-tested, reliable
- Full hardware support
- Rich networking stack
- Standard Linux APIs

### initramfs
- Compressed CPIO archive
- Loaded into RAM by kernel
- Contains:
  - Your application as `/init`
  - Required shared libraries
  - Directory structure for kernel interfaces

**Format:** `newc` CPIO format, gzip-compressed

### NativeAOT Binary
- Ahead-of-time compiled .NET code
- Native ELF executable
- No .NET runtime overhead
- Minimal dependencies (typically just libc)

**Compilation process:**
1. C# source → IL (Intermediate Language)
2. IL → Native Code (via ILC compiler)
3. Link with native dependencies
4. Strip symbols for size optimization

## Memory Layout

```
┌──────────────────────────────┐ High Memory
│      Kernel Space            │
│  - Kernel Code               │
│  - Kernel Data               │
│  - Device Drivers            │
├──────────────────────────────┤
│      User Space              │
│  ┌──────────────────────┐    │
│  │  Application Heap    │    │
│  │  (Dynamic Memory)    │    │
│  ├──────────────────────┤    │
│  │  Application Stack   │    │
│  ├──────────────────────┤    │
│  │  Shared Libraries    │    │
│  │  (libc, etc.)        │    │
│  ├──────────────────────┤    │
│  │  Application Code    │    │
│  │  (.NET Binary)       │    │
│  └──────────────────────┘    │
├──────────────────────────────┤
│      initramfs in RAM        │
│  (mounted as /)              │
└──────────────────────────────┘ Low Memory
```

## Process Hierarchy

Traditional Linux system:
```
init (PID 1)
├── systemd/other services
├── getty (login terminals)
├── network manager
├── your application
└── ... many other processes
```

Our unikernel approach:
```
Your .NET App (PID 1)
└── (no other processes)
```

## Advantages

### 1. **Simplicity**
- No complex init system (systemd, init.d)
- No package management
- No multi-user complexity

### 2. **Performance**
- Instant startup (no JIT compilation)
- Minimal memory footprint
- No process context switching overhead
- Direct hardware access via kernel APIs

### 3. **Security**
- Minimal attack surface
- No unnecessary services running
- Reduced dependency chain
- Easy to audit

### 4. **Portability**
- Single binary contains everything
- Reproducible builds
- Easy deployment

### 5. **Development Efficiency**
- Write in C# (high-level, safe language)
- Rich .NET libraries available
- Fast iteration with QEMU
- Familiar debugging tools

## Comparison: Traditional vs Unikernel

| Aspect | Traditional Linux | Our Unikernel |
|--------|------------------|---------------|
| Init System | systemd/init | Your .NET app |
| Process Count | Hundreds | 1 |
| Memory Usage | GBs | MBs |
| Boot Time | 10-60s | 1-5s |
| Complexity | High | Low |
| Flexibility | Very High | Moderate |
| Security Surface | Large | Minimal |

## NativeAOT Compilation Details

### Compilation Pipeline

```
Program.cs (C# Source)
    ↓
[Roslyn Compiler]
    ↓
IL (Intermediate Language)
    ↓
[ILC - IL Compiler]
    ↓
Object Files (.o)
    ↓
[Native Linker]
    ↓
ELF Executable
```

### Size Optimizations

The project uses several optimization flags:

- **`InvariantGlobalization=true`**: Removes culture-specific data (~500KB savings)
- **`StripSymbols=true`**: Removes debug symbols
- **`IlcOptimizationPreference=Size`**: Optimizes for binary size
- **Tree shaking**: Removes unused code automatically

### Dependencies

The binary typically depends on:
- `libc.so.6`: Standard C library
- `ld-linux-x86-64.so.2`: Dynamic linker

For fully static builds, you can use musl-libc or configure static linking.

## Extending the System

### Adding Features

You can extend the unikernel by:

1. **Including files in initramfs:**
   ```bash
   # In create-initramfs.sh
   mkdir -p "$ROOTFS_DIR/data"
   cp my-config.json "$ROOTFS_DIR/data/"
   ```

2. **Adding network capabilities:**
   - Use `HttpClient` for client operations
   - Use `HttpListener` for server operations
   - Use sockets for low-level networking

3. **Accessing hardware:**
   - Read/write files in `/dev/`
   - Use `/proc/` for process information
   - Use `/sys/` for hardware information

4. **Persistent storage:**
   - Mount disk images in QEMU
   - Access block devices from .NET
   - Implement filesystem operations

## Limitations

### What This Is NOT

This is **not** a true unikernel in the academic sense because:
- Still uses a general-purpose Linux kernel (not specialized)
- Has kernel-userspace separation (not single address space)
- Uses standard Linux system calls (not library OS)

### What It IS

A pragmatic approach that:
- Gives you a single-application OS
- Provides the benefits of simplified deployment
- Maintains compatibility with Linux APIs
- Offers fast iteration and development

### True Unikernels

For comparison, true unikernels like MirageOS or IncludeOS:
- Compile your application with a library OS
- No kernel-userspace separation
- Specialized, minimal kernel
- Run directly on hypervisor or hardware
- More complex to develop and debug

## UEFI Alternative Path

For a kernel-less approach, you could:

1. Compile .NET code to UEFI application
2. Boot directly from UEFI firmware
3. Implement hardware drivers in C#

**Challenges:**
- NativeAOT doesn't target EFI directly
- Need custom toolchain modifications
- Must implement drivers from scratch
- More complex development

**When to use:**
- Need kernel-less operation
- Want absolute minimal system
- Have specific hardware requirements
- Don't need Linux API compatibility

## Further Reading

- [.NET NativeAOT Documentation](https://learn.microsoft.com/en-us/dotnet/core/deploying/native-aot/)
- [Linux Boot Process](https://www.kernel.org/doc/html/latest/admin-guide/initrd.html)
- [initramfs Documentation](https://www.kernel.org/doc/html/latest/filesystems/ramfs-rootfs-initramfs.html)
- [Unikernels Explained](http://unikernel.org/)
- [QEMU Documentation](https://www.qemu.org/docs/master/)
