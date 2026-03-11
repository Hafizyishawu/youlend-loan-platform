namespace LoanApi.Models;

/// <summary>
/// Represents a loan in the system
/// </summary>
public class Loan
{
    /// <summary>
    /// Unique identifier for the loan (GUID)
    /// </summary>
    public Guid LoanId { get; set; }

    /// <summary>
    /// Name of the borrower (Required)
    /// </summary>
    public string BorrowerName { get; set; } = string.Empty;

    /// <summary>
    /// Amount to be repaid by borrower (Bonus requirement)
    /// </summary>
    public decimal RepaymentAmount { get; set; }

    /// <summary>
    /// Amount funded to borrower (Bonus requirement)
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
