using System;

class Program
{
    static void Main()
    {
        Console.WriteLine("===========================================");
        Console.WriteLine("Hello from .NET NativeAOT initramfs!");
        Console.WriteLine("===========================================");
        Console.WriteLine();
        Console.WriteLine("This is a NativeAOT .NET 9 binary running");
        Console.WriteLine("as the init process in a Linux initramfs.");
        Console.WriteLine();
        Console.WriteLine("System Information:");
        Console.WriteLine($"  OS: {Environment.OSVersion}");
        Console.WriteLine($"  .NET Version: {Environment.Version}");
        Console.WriteLine($"  64-bit OS: {Environment.Is64BitOperatingSystem}");
        Console.WriteLine($"  64-bit Process: {Environment.Is64BitProcess}");
        Console.WriteLine($"  Processor Count: {Environment.ProcessorCount}");
        Console.WriteLine();
        Console.WriteLine("This demonstrates a minimal 'unikernel-like'");
        Console.WriteLine("environment with just the Linux kernel and");
        Console.WriteLine("a single .NET application.");
        Console.WriteLine();
        Console.WriteLine("===========================================");
        
        // Only wait for input if we have an interactive console
        if (Environment.UserInteractive && !Console.IsInputRedirected)
        {
            Console.WriteLine("Press any key to shutdown...");
            Console.ReadKey(true);
        }
        else
        {
            Console.WriteLine("Running in non-interactive mode.");
            Console.WriteLine("Waiting 5 seconds before shutdown...");
            System.Threading.Thread.Sleep(5000);
        }
        
        Console.WriteLine("Shutting down...");
    }
}
