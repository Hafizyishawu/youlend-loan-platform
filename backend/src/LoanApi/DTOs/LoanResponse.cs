namespace LoanApi.DTOs;

/// <summary>
/// Response DTO for loan data
/// </summary>
public class LoanResponse
{
    /// <summary>
    /// Unique identifier for the loan
    /// </summary>
    public Guid LoanId { get; set; }

    /// <summary>
    /// Name of the borrower
    /// </summary>
    public string BorrowerName { get; set; } = string.Empty;

    /// <summary>
    /// Amount to be repaid by borrower
    /// </summary>
    public decimal RepaymentAmount { get; set; }

    /// <summary>
    /// Amount funded to borrower
    /// </summary>
    public decimal FundingAmount { get; set; }

    /// <summary>
    /// Date when the loan was created
    /// </summary>
    public DateTime CreatedAt { get; set; }

    /// <summary>
    /// Date when the loan was last updated
    /// </summary>
    public DateTime UpdatedAt { get; set; }
}
