using LoanApi.Extensions;
using LoanApi.Middleware;
using Microsoft.OpenApi.Models;
using Prometheus;
using Serilog;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .Enrich.FromLogContext()
    .Enrich.WithProperty("Application", "LoanApi")
    .WriteTo.Console(outputTemplate: "[{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz}] [{Level:u3}] [{CorrelationId}] {Message:lj}{NewLine}{Exception}")
    .CreateLogger();

builder.Host.UseSerilog();

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Swagger/OpenAPI configuration
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "YouLend Loan Management API",
        Version = "v1",
        Description = "REST API for managing loans - YouLend Platform Engineer Assessment",
        Contact = new OpenApiContact
        {
            Name = "Abdul Hafiz Yishawu",
            Email = "abdul@example.com"
        }
    });

    // Include XML comments
    var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
    {
        c.IncludeXmlComments(xmlPath);
    }
});

// Application services
builder.Services.AddApplicationServices();

// FluentValidation
builder.Services.AddValidators();

// CORS
builder.Services.AddCorsConfiguration();

// Health checks
builder.Services.AddHealthChecks();

// Prometheus metrics
builder.Services.UseHttpClientMetrics();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Loan API v1");
        c.RoutePrefix = string.Empty; // Swagger at root
    });
}

// Security headers
app.Use(async (context, next) =>
{
    context.Response.Headers.Append("X-Content-Type-Options", "nosniff");
    context.Response.Headers.Append("X-Frame-Options", "DENY");
    context.Response.Headers.Append("X-XSS-Protection", "1; mode=block");
    context.Response.Headers.Append("Referrer-Policy", "no-referrer");
    context.Response.Headers.Append("Content-Security-Policy", "default-src 'self'");

    await next();
});

// Custom middleware (order matters!)
app.UseMiddleware<RequestLoggingMiddleware>();
app.UseMiddleware<ExceptionHandlingMiddleware>();

// HTTPS redirection
app.UseHttpsRedirection();

// CORS
app.UseCors("AllowFrontend");

// Prometheus metrics endpoint
app.UseMetricServer();
app.UseHttpMetrics();

// Authorization
app.UseAuthorization();

// Map controllers
app.MapControllers();

// Health check endpoints
app.MapHealthChecks("/health/live", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
{
    Predicate = _ => false // Liveness - always returns healthy if app is running
});

app.MapHealthChecks("/health/ready", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
{
    Predicate = _ => true // Readiness - checks all registered health checks
});

// Startup logging
Log.Information("Starting YouLend Loan Management API");
Log.Information("Environment: {Environment}", app.Environment.EnvironmentName);

try
{
    app.Run();
    Log.Information("Application stopped gracefully");
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
    throw;
}
finally
{
    Log.CloseAndFlush();
}

public partial class Program { }