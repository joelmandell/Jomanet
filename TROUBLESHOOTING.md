# Troubleshooting Guide

This guide helps you diagnose and fix common issues when building and running the NativeAOT unikernel.

## Build Issues

### Issue: .NET SDK Not Found

**Error:**
```
bash: dotnet: command not found
```

**Solution:**
Install .NET 9 SDK:
```bash
# Ubuntu/Debian
wget https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 9.0

# Or use package manager
sudo apt-get install dotnet-sdk-9.0
```

### Issue: NativeAOT Compilation Fails

**Error:**
```
error : System.PlatformNotSupportedException: NativeAOT is not supported on this platform
```

**Solution:**
- Ensure you're on Linux x64
- Check .NET version: `dotnet --version` (must be 9.0+)
- Verify platform: `uname -m` (should be x86_64)

### Issue: Build Fails with Linker Errors

**Error:**
```
error : Unable to find required libraries
```

**Solution:**
Install build essentials:
```bash
sudo apt-get install build-essential zlib1g-dev
```

### Issue: Out of Memory During Build

**Error:**
```
fatal error: out of memory
```

**Solution:**
- Free up memory: `free -h`
- Close other applications
- Increase swap space
- Use `-p:IlcOptimizationPreference=Size` to reduce memory usage

## Runtime Issues

### Issue: Binary Crashes with Segmentation Fault

**Symptom:**
```
Segmentation fault (core dumped)
```

**Diagnosis:**
```bash
# Check dependencies
ldd build/nativeaot/UniKernelApp

# Run with debugging
gdb build/nativeaot/UniKernelApp
```

**Common Causes:**
1. Missing libraries in initramfs
2. Incompatible libc version
3. Corrupted binary

**Solution:**
```bash
# Rebuild from scratch
rm -rf build/
./scripts/build-all.sh

# Verify libraries were copied
ls -R build/rootfs/lib
```

### Issue: Cannot Read Console Input

**Error:**
```
System.InvalidOperationException: Cannot read keys when console input has been redirected
```

**Solution:**
This is expected when running in non-interactive mode. The updated code handles this gracefully:
```csharp
if (Environment.UserInteractive && !Console.IsInputRedirected)
{
    Console.ReadKey(true);
}
```

### Issue: Binary Won't Execute

**Error:**
```
bash: ./UniKernelApp: cannot execute binary file: Exec format error
```

**Diagnosis:**
```bash
file build/nativeaot/UniKernelApp
# Should show: ELF 64-bit LSB executable, x86-64
```

**Solution:**
- Ensure you built for the correct platform (`linux-x64`)
- Verify the binary is not corrupted
- Check execute permissions: `chmod +x build/nativeaot/UniKernelApp`

## initramfs Issues

### Issue: initramfs Creation Fails

**Error:**
```
find: No such file or directory
```

**Solution:**
Ensure the NativeAOT binary was built first:
```bash
./scripts/build-nativeaot.sh
./scripts/create-initramfs.sh
```

### Issue: Large initramfs Size

**Symptom:**
```
-rw-rw-r-- 1 user user 50M initramfs.cpio.gz
```

**Diagnosis:**
```bash
# Check rootfs contents
du -sh build/rootfs/*

# List large files
find build/rootfs -type f -size +1M -exec ls -lh {} \;
```

**Solution:**
- Enable size optimizations in .csproj
- Use `StripSymbols=true`
- Remove unnecessary dependencies
- Consider static linking

### Issue: Missing Libraries in initramfs

**Symptom:**
Binary works on host but fails in QEMU

**Diagnosis:**
```bash
# Check what libraries are needed
ldd build/nativeaot/UniKernelApp

# Check what was copied to initramfs
find build/rootfs -name "*.so*"
```

**Solution:**
The script automatically copies dependencies. If something is missing:
```bash
# Manually add to rootfs
cp /path/to/library.so build/rootfs/lib/
./scripts/create-initramfs.sh
```

## QEMU Issues

### Issue: QEMU Not Found

**Error:**
```
Error: qemu-system-x86_64 not found
```

**Solution:**
Install QEMU:
```bash
# Ubuntu/Debian
sudo apt-get install qemu-system-x86

# Fedora
sudo dnf install qemu-system-x86

# Arch
sudo pacman -S qemu-system-x86
```

### Issue: No Kernel Found

**Error:**
```
Error: Kernel not found at build/kernel/bzImage
```

**Solution:**
```bash
# Copy system kernel
sudo cp /boot/vmlinuz-$(uname -r) build/kernel/bzImage

# Or run the script
./scripts/get-kernel.sh
```

### Issue: QEMU Hangs or Shows Nothing

**Symptom:**
QEMU window is black or text stops appearing

**Diagnosis:**
- Check if using `-nographic` correctly
- Verify kernel command line includes `console=ttyS0`

**Solution:**
```bash
# Try with debug output
qemu-system-x86_64 \
    -kernel build/kernel/bzImage \
    -initrd build/initramfs/initramfs.cpio.gz \
    -append "console=ttyS0 rdinit=/init debug" \
    -nographic \
    -serial mon:stdio
```

### Issue: Kernel Panic in QEMU

**Error:**
```
Kernel panic - not syncing: No working init found
```

**Common Causes:**
1. `/init` not found in initramfs
2. `/init` not executable
3. Missing dependencies for `/init`

**Solution:**
```bash
# Verify init exists and is executable
ls -lh build/rootfs/init
# Should show: -rwxrwxr-x

# Check initramfs contents
mkdir -p /tmp/test-initramfs
cd /tmp/test-initramfs
gunzip -c /home/runner/work/Jomanet/Jomanet/build/initramfs/initramfs.cpio.gz | cpio -idv
ls -la init
```

### Issue: Cannot Exit QEMU

**Symptom:**
Stuck in QEMU, Ctrl+C doesn't work

**Solution:**
- Press `Ctrl+A`, then `X` to exit QEMU
- Or from another terminal: `killall qemu-system-x86_64`

## Networking Issues

### Issue: Cannot Access HTTP Server in QEMU

**Symptom:**
HTTP server starts but cannot connect from host

**Solution:**
Add port forwarding to QEMU:
```bash
qemu-system-x86_64 \
    -kernel build/kernel/bzImage \
    -initrd build/initramfs/initramfs.cpio.gz \
    -append "console=ttyS0 rdinit=/init" \
    -nographic \
    -netdev user,id=net0,hostfwd=tcp::8080-:8080 \
    -device e1000,netdev=net0
```

### Issue: HttpListener Requires Privileges

**Error:**
```
Access denied: HttpListener requires administrator privileges
```

**Solution:**
Run with sudo:
```bash
sudo ./build/nativeaot/UniKernelApp
```

Or configure HTTP.SYS permissions (Windows) or capabilities (Linux):
```bash
# Linux: Add capability
sudo setcap 'cap_net_bind_service=+ep' build/nativeaot/UniKernelApp
```

## Performance Issues

### Issue: Slow Build Times

**Symptom:**
NativeAOT compilation takes several minutes

**Solutions:**
1. Use incremental builds (don't clean every time)
2. Reduce optimization level temporarily during development
3. Use a faster machine or cloud build
4. Enable parallel compilation

### Issue: Large Binary Size

**Symptom:**
Binary is larger than expected (>5MB)

**Diagnosis:**
```bash
# Check binary size
ls -lh build/nativeaot/UniKernelApp

# Check if symbols are stripped
file build/nativeaot/UniKernelApp | grep stripped
```

**Solution:**
Ensure these are in your .csproj:
```xml
<StripSymbols>true</StripSymbols>
<IlcOptimizationPreference>Size</IlcOptimizationPreference>
<InvariantGlobalization>true</InvariantGlobalization>
```

### Issue: High Memory Usage

**Symptom:**
Application uses more memory than expected

**Diagnosis:**
```bash
# Check memory usage
./build/nativeaot/UniKernelApp &
ps aux | grep UniKernelApp
```

**Solution:**
- Review memory allocations in code
- Disable unnecessary features
- Use value types instead of reference types where possible
- Pool objects instead of creating new ones

## Debugging Tips

### Enable Verbose Output

Add debug flags to kernel command line:
```bash
-append "console=ttyS0 rdinit=/init debug loglevel=7"
```

### Debug the Binary Outside QEMU

Always test your binary directly first:
```bash
./build/nativeaot/UniKernelApp
```

This isolates whether the issue is with your code or the boot process.

### Check System Logs

In QEMU, kernel messages are shown on the console. Look for:
- "Kernel panic" messages
- "Segmentation fault" errors
- Library loading errors

### Use strace for System Call Tracing

```bash
strace -f ./build/nativeaot/UniKernelApp
```

This shows all system calls made by your application.

### Test with a Minimal App

If things aren't working, try with the simplest possible app:
```csharp
class Program
{
    static void Main()
    {
        System.Console.WriteLine("Hello!");
    }
}
```

## Getting Help

If you're still stuck:

1. **Check build logs carefully** - errors are usually explicit
2. **Test components individually** - isolate the problem
3. **Compare with working examples** - use the provided samples
4. **Check .NET NativeAOT documentation** - for compilation issues
5. **Review QEMU documentation** - for virtualization issues
6. **Search for similar errors** - others may have encountered the same issue

## Common Pitfalls

1. **Not running `build-nativeaot.sh` before `create-initramfs.sh`**
   - Scripts must be run in order

2. **Modifying scripts on Windows**
   - Line endings may be converted to CRLF
   - Use `dos2unix` to fix

3. **Using the wrong .NET runtime**
   - Must use .NET 9.0 or later
   - Check with `dotnet --version`

4. **Missing execute permissions**
   - Scripts must be executable: `chmod +x scripts/*.sh`

5. **Running out of disk space**
   - Build artifacts can be large
   - Check with `df -h`

6. **Kernel version mismatch**
   - Use a recent kernel (5.0+)
   - Check with `uname -r`
