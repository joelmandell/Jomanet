using System;
using System.Net;
using System.Text;
using System.Threading;

class Program
{
    static void Main()
    {
        Console.WriteLine("===========================================");
        Console.WriteLine("Minimal HTTP Server - NativeAOT Unikernel");
        Console.WriteLine("===========================================");
        Console.WriteLine();
        
        const string url = "http://+:8080/";
        
        try
        {
            using var listener = new HttpListener();
            listener.Prefixes.Add(url);
            listener.Start();
            
            Console.WriteLine($"HTTP Server listening on port 8080");
            Console.WriteLine($"Server started at: {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC");
            Console.WriteLine();
            Console.WriteLine("System Information:");
            Console.WriteLine($"  OS: {Environment.OSVersion}");
            Console.WriteLine($"  .NET Version: {Environment.Version}");
            Console.WriteLine($"  Processor Count: {Environment.ProcessorCount}");
            Console.WriteLine();
            Console.WriteLine("Press Ctrl+C to stop...");
            Console.WriteLine("===========================================");
            Console.WriteLine();
            
            int requestCount = 0;
            
            while (true)
            {
                try
                {
                    var context = listener.GetContext();
                    requestCount++;
                    
                    var request = context.Request;
                    var response = context.Response;
                    
                    Console.WriteLine($"[{DateTime.UtcNow:HH:mm:ss}] Request #{requestCount}: {request.HttpMethod} {request.Url?.PathAndQuery}");
                    
                    var responseBody = BuildHtmlResponse(requestCount);
                    var buffer = Encoding.UTF8.GetBytes(responseBody);
                    
                    response.ContentType = "text/html; charset=utf-8";
                    response.ContentLength64 = buffer.Length;
                    response.OutputStream.Write(buffer, 0, buffer.Length);
                    response.OutputStream.Close();
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error handling request: {ex.Message}");
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Server error: {ex.Message}");
            Console.WriteLine("Note: HttpListener requires administrator privileges.");
            Console.WriteLine("Run with sudo or configure HTTP.SYS permissions.");
        }
    }
    
    static string BuildHtmlResponse(int requestNumber)
    {
        return $@"<!DOCTYPE html>
<html>
<head>
    <title>NativeAOT Unikernel</title>
    <style>
        body {{ font-family: monospace; max-width: 800px; margin: 50px auto; padding: 20px; }}
        h1 {{ color: #2c3e50; }}
        .info {{ background: #ecf0f1; padding: 15px; border-radius: 5px; margin: 10px 0; }}
        .stat {{ margin: 5px 0; }}
    </style>
</head>
<body>
    <h1>🚀 NativeAOT Unikernel HTTP Server</h1>
    
    <div class=""info"">
        <h2>Server Information</h2>
        <div class=""stat""><strong>Request Number:</strong> {requestNumber}</div>
        <div class=""stat""><strong>Server Time:</strong> {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC</div>
        <div class=""stat""><strong>OS:</strong> {Environment.OSVersion}</div>
        <div class=""stat""><strong>.NET Version:</strong> {Environment.Version}</div>
        <div class=""stat""><strong>64-bit Process:</strong> {Environment.Is64BitProcess}</div>
        <div class=""stat""><strong>Processor Count:</strong> {Environment.ProcessorCount}</div>
        <div class=""stat""><strong>Working Set:</strong> {Environment.WorkingSet / 1024 / 1024} MB</div>
    </div>
    
    <div class=""info"">
        <h2>What is this?</h2>
        <p>This is a minimal HTTP server written in C# and compiled to native code using .NET NativeAOT.</p>
        <p>It runs as the init process (PID 1) in a Linux initramfs, creating a ""unikernel-like"" environment.</p>
        <p>The entire system consists of just:</p>
        <ul>
            <li>Linux kernel</li>
            <li>This .NET application</li>
            <li>Minimal shared libraries (libc, ld-linux)</li>
        </ul>
    </div>
    
    <div class=""info"">
        <h2>Performance Benefits</h2>
        <ul>
            <li>✓ Instant startup (no JIT compilation)</li>
            <li>✓ Small binary size (~1-2 MB)</li>
            <li>✓ Low memory footprint</li>
            <li>✓ Ahead-of-time compiled native code</li>
        </ul>
    </div>
</body>
</html>";
    }
}
