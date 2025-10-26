# HTTP Server Example

A minimal HTTP server running as a NativeAOT unikernel.

## Description

This example demonstrates a practical use case for the NativeAOT unikernel approach: a lightweight HTTP server that runs as the init process in a Linux initramfs.

## Features

- Minimal HTTP server using `HttpListener`
- Serves a dynamic HTML page with system information
- Displays request statistics
- Runs as PID 1 in the unikernel environment

## Building

To build this example as a unikernel:

1. **Build the NativeAOT binary:**
   ```bash
   cd examples/HttpServer/HttpServer
   dotnet publish -c Release -r linux-x64 -p:PublishAot=true --self-contained true -o ../../../build/http-server
   ```

2. **Create custom build script** (or modify the existing scripts to use this project)

3. **Test locally first:**
   ```bash
   sudo ./build/http-server/HttpServer
   # Visit http://localhost:8080 in your browser
   ```

Note: HttpListener requires elevated privileges (sudo) to bind to ports.

## Customization Ideas

This HTTP server can be extended to:

- Serve static files from the initramfs
- Provide a REST API for system management
- Act as a reverse proxy
- Monitor and control system services
- Provide a web-based dashboard

## Network Configuration in QEMU

To access the HTTP server from your host when running in QEMU, you'll need to configure port forwarding:

```bash
qemu-system-x86_64 \
    -kernel build/kernel/bzImage \
    -initrd build/initramfs/initramfs.cpio.gz \
    -append "console=ttyS0 rdinit=/init" \
    -nographic \
    -m 512M \
    -smp 2 \
    -netdev user,id=net0,hostfwd=tcp::8080-:8080 \
    -device e1000,netdev=net0
```

Then visit `http://localhost:8080` on your host machine.

## Performance

This demonstrates the efficiency of the NativeAOT approach:

- **Binary size**: ~1-2 MB
- **Memory usage**: ~20-40 MB total
- **Startup time**: Instant (no JIT)
- **Request latency**: Microseconds

## Use Cases

This pattern is ideal for:

- Embedded web servers
- IoT devices with web interfaces
- Microservices in containerized environments
- Edge computing applications
- Network appliances
