using System.Diagnostics;

namespace LoanApi.Middleware;

/// <summary>
/// Middleware for logging HTTP requests with correlation IDs and timing
/// </summary>
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var correlationId = context.TraceIdentifier;

        // Add correlation ID to response headers
        context.Response.OnStarting(() =>
        {
            context.Response.Headers.Append("X-Correlation-ID", correlationId);
            return Task.CompletedTask;
        });

        var stopwatch = Stopwatch.StartNew();

        // Sanitize path to prevent log injection
        var safePath = context.Request.Path.ToString()  
            .Replace("\r", string.Empty)
            .Replace("\n", string.Empty)
            .Replace("\t", string.Empty);

        _logger.LogInformation(
            "HTTP {Method} {Path} started. CorrelationId: {CorrelationId}",
            context.Request.Method,
            safePath,
            correlationId);

        try
        {
            await _next(context);
        }
        finally
        {
            stopwatch.Stop();

            _logger.LogInformation(
                "HTTP {Method} {Path} completed with {StatusCode} in {ElapsedMilliseconds}ms. CorrelationId: {CorrelationId}",
                context.Request.Method,
                safePath,
                context.Response.StatusCode,
                stopwatch.ElapsedMilliseconds,
                correlationId);
        }
    }
}