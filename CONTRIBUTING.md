# Contributing Guide

Thank you for your interest in contributing to the NativeAOT Unikernel project! This guide will help you get started.

## Development Setup

1. **Prerequisites:**
   - .NET 9 SDK or later
   - Linux operating system (or WSL2 on Windows)
   - Git
   - Basic build tools (`build-essential` on Ubuntu)
   - Optional: QEMU for testing

2. **Clone and Build:**
   ```bash
   git clone https://github.com/joelmandell/Jomanet.git
   cd Jomanet
   ./scripts/build-all.sh
   ```

3. **Test:**
   ```bash
   ./build/nativeaot/UniKernelApp
   ```

## Project Structure

```
Jomanet/
├── src/               # Main application source
│   └── UniKernelApp/  # Default NativeAOT application
├── scripts/           # Build and boot automation
├── examples/          # Example applications
├── docs/              # Additional documentation (if any)
├── README.md          # Main documentation
├── ARCHITECTURE.md    # Technical architecture details
└── TROUBLESHOOTING.md # Common issues and solutions
```

## How to Contribute

### Reporting Issues

When reporting bugs or issues:
1. Check if the issue already exists
2. Include your environment details:
   - OS and version
   - .NET SDK version
   - Kernel version (if applicable)
3. Provide steps to reproduce
4. Include relevant error messages

### Suggesting Features

For feature requests:
1. Describe the use case
2. Explain the expected behavior
3. Consider backwards compatibility
4. Provide examples if possible

### Contributing Code

1. **Fork the repository**
2. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes:**
   - Follow the existing code style
   - Add tests if applicable
   - Update documentation as needed

4. **Test your changes:**
   ```bash
   ./scripts/build-all.sh
   ./build/nativeaot/UniKernelApp
   ```

5. **Commit with descriptive messages:**
   ```bash
   git commit -m "Add feature: brief description"
   ```

6. **Push and create a Pull Request:**
   ```bash
   git push origin feature/your-feature-name
   ```

## Code Guidelines

### C# Code Style

- Use meaningful variable names
- Add comments for complex logic
- Follow .NET naming conventions
- Keep methods focused and small
- Handle errors appropriately

### Example:
```csharp
// Good
public void ProcessRequest(HttpListenerContext context)
{
    try
    {
        // Handle the request
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error processing request: {ex.Message}");
    }
}

// Avoid
public void pr(object c) { /* ... */ }
```

### Shell Script Style

- Use `set -e` to fail on errors
- Add comments explaining complex commands
- Use variables for paths
- Quote variables to handle spaces
- Check for required tools/files

### Example:
```bash
#!/bin/bash
set -e

# Build the NativeAOT binary
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/src/UniKernelApp"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Project directory not found"
    exit 1
fi

dotnet publish "$PROJECT_DIR" -o output/
```

## Adding Examples

To add a new example application:

1. **Create the project:**
   ```bash
   mkdir -p examples/YourExample
   cd examples/YourExample
   dotnet new console -n YourExample
   ```

2. **Configure for NativeAOT:**
   Edit `YourExample.csproj`:
   ```xml
   <PropertyGroup>
     <PublishAot>true</PublishAot>
     <InvariantGlobalization>true</InvariantGlobalization>
     <StripSymbols>true</StripSymbols>
   </PropertyGroup>
   ```

3. **Add documentation:**
   Create `examples/YourExample/README.md` explaining:
   - What the example does
   - How to build it
   - How to run it
   - Any special configuration

4. **Test thoroughly:**
   - Build as NativeAOT
   - Test outside QEMU first
   - Test in QEMU if applicable
   - Document any issues

## Improving Build Scripts

When modifying build scripts:

1. **Maintain backwards compatibility**
2. **Add error checking:**
   ```bash
   if [ ! -f "$REQUIRED_FILE" ]; then
       echo "Error: Required file not found"
       exit 1
   fi
   ```

3. **Provide helpful output:**
   ```bash
   echo "=== Building Component ==="
   echo "Source: $SOURCE_DIR"
   echo "Output: $OUTPUT_DIR"
   ```

4. **Test on a clean environment:**
   ```bash
   rm -rf build/
   ./scripts/build-all.sh
   ```

## Documentation

### When to Update Documentation

Update documentation when you:
- Add new features
- Change existing behavior
- Fix bugs that affect usage
- Add examples
- Modify build process

### Documentation Files

- **README.md**: Quick start, basic usage
- **ARCHITECTURE.md**: Technical details, design decisions
- **TROUBLESHOOTING.md**: Common issues, solutions
- **examples/*/README.md**: Example-specific documentation

### Documentation Style

- Use clear, concise language
- Include code examples
- Add command-line examples with output
- Use headings to organize content
- Link to related documentation

## Testing

### Manual Testing Checklist

Before submitting:

- [ ] Code builds without errors
- [ ] Binary runs directly on Linux
- [ ] initramfs creates successfully
- [ ] Documentation is updated
- [ ] Examples work as described
- [ ] Scripts have proper error handling
- [ ] No sensitive information in commits

### Testing New Examples

1. Build the NativeAOT binary
2. Run directly on host
3. Create initramfs with the binary
4. Test in QEMU (if QEMU available)
5. Verify documentation is accurate

## Performance Considerations

When contributing code:

1. **Keep binaries small:**
   - Use size optimizations
   - Minimize dependencies
   - Remove unused code

2. **Optimize startup time:**
   - Avoid expensive initialization
   - Lazy load when possible

3. **Memory efficiency:**
   - Use value types appropriately
   - Pool objects when beneficial
   - Dispose resources properly

## Security Considerations

1. **No hardcoded secrets**
2. **Validate all inputs**
3. **Handle errors securely** (don't leak information)
4. **Use HTTPS for network communication**
5. **Follow principle of least privilege**

## Questions or Need Help?

- Create an issue for questions
- Check existing issues and documentation first
- Be patient and respectful

## Recognition

Contributors will be recognized in:
- Git commit history
- Release notes (for significant contributions)
- Project documentation (for major features)

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

## Code of Conduct

- Be respectful and professional
- Welcome newcomers
- Focus on constructive feedback
- Assume good intentions

Thank you for contributing to make this project better!
