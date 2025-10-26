# Examples

This directory contains example customizations for the NativeAOT unikernel.

## Available Examples

### 1. HTTP Server (Coming Soon)
A minimal HTTP server running as the init process.

### 2. System Monitor (Coming Soon)
Real-time system monitoring and metrics collection.

### 3. Network Tool (Coming Soon)
Network diagnostics and testing tool.

## Creating Your Own Examples

To create a custom unikernel:

1. Create a new C# console project in `src/`
2. Configure it for NativeAOT in the `.csproj` file
3. Modify the build scripts to use your project
4. Build and test!

### Example .csproj Configuration

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net9.0</TargetFramework>
    <PublishAot>true</PublishAot>
    <InvariantGlobalization>true</InvariantGlobalization>
    <StripSymbols>true</StripSymbols>
    <IlcOptimizationPreference>Size</IlcOptimizationPreference>
  </PropertyGroup>
</Project>
```

### Key Points for Unikernel Development

1. **Keep it minimal**: The smaller your binary, the faster it boots
2. **Handle signals**: As init (PID 1), you need to handle termination properly
3. **No dependencies**: Minimize external library dependencies
4. **Static vs Dynamic**: Consider if you want a fully static binary
5. **Testing**: Test outside QEMU first to catch issues early

### Advanced: Fully Static Binary

For a truly standalone binary with no dependencies, you can:

1. Use Alpine Linux musl-based toolchain
2. Configure NativeAOT for static linking
3. Remove all glibc dependencies

Example build command:
```bash
dotnet publish -c Release -r linux-musl-x64 -p:PublishAot=true
```

Note: This requires the musl-based .NET SDK.
