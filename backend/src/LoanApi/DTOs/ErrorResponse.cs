namespace LoanApi.DTOs;

/// <summary>
/// Standardized error response DTO
/// </summary>
public class ErrorResponse
{
    /// <summary>
    /// Error message
    /// </summary>
    public string Message { get; set; } = string.Empty;

    /// <summary>
    /// HTTP status code
    /// </summary>
    public int StatusCode { get; set; }

    /// <summary>
    /// Correlation ID for tracking the request
    /// </summary>
    public string CorrelationId { get; set; } = string.Empty;

    /// <summary>
    /// Timestamp when the error occurred
    /// </summary>
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// Validation errors (if applicable)
    /// </summary>
    public Dictionary<string, string[]>? ValidationErrors { get; set; }
}
