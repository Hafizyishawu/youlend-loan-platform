namespace LoanApi.DTOs;

/// <summary>
/// Request DTO for updating an existing loan
/// </summary>
public class UpdateLoanRequest
{
    /// <summary>
    /// Name of the borrower (Required, 1-100 characters)
    /// </summary>
    public string BorrowerName { get; set; } = string.Empty;

    /// <summary>
    /// Amount to be repaid by borrower (Must be positive)
    /// </summary>
    public decimal RepaymentAmount { get; set; }

    /// <summary>
    /// Amount funded to borrower (Must be positive)
    /// </summary>
    public decimal FundingAmount { get; set; }
}
