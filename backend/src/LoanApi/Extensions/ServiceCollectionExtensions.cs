using FluentValidation;
using FluentValidation.AspNetCore;
using LoanApi.Repositories;
using LoanApi.Services;
using LoanApi.Validators;

namespace LoanApi.Extensions;

/// <summary>
/// Extension methods for IServiceCollection
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Adds application services to the DI container
    /// </summary>
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        // Register repositories
        services.AddSingleton<ILoanRepository, InMemoryLoanRepository>();

        // Register services
        services.AddScoped<ILoanService, LoanService>();

        return services;
    }

    /// <summary>
    /// Adds FluentValidation validators
    /// </summary>
    public static IServiceCollection AddValidators(this IServiceCollection services)
    {
        services.AddFluentValidationAutoValidation();
        services.AddValidatorsFromAssemblyContaining<CreateLoanRequestValidator>();

        return services;
    }

    /// <summary>
    /// Adds CORS configuration
    /// </summary>
    public static IServiceCollection AddCorsConfiguration(this IServiceCollection services)
    {
        services.AddCors(options =>
        {
            options.AddPolicy("AllowFrontend", builder =>
            {
                builder
                    .WithOrigins(
                        "http://localhost:4200",
                        "http://localhost:3000",
                        "https://localhost:4200",
                        "https://localhost:3000"
                    )
                    .AllowAnyMethod()
                    .AllowAnyHeader()
                    .WithExposedHeaders("X-Correlation-ID")
                    .AllowCredentials();
            });
        });

        return services;
    }
}
