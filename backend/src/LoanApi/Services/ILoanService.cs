using LoanApi.DTOs;

namespace LoanApi.Services;

/// <summary>
/// Service interface for loan business logic
/// </summary>
public interface ILoanService
{
    /// <summary>
    /// Creates a new loan
    /// </summary>
    Task<LoanResponse> CreateLoanAsync(CreateLoanRequest request);

    /// <summary>
    /// Gets a loan by ID
    /// </summary>
    Task<LoanResponse?> GetLoanByIdAsync(Guid loanId);

    /// <summary>
    /// Gets all loans
    /// </summary>
    Task<IEnumerable<LoanResponse>> GetAllLoansAsync();

    /// <summary>
    /// Gets loans by borrower name
    /// </summary>
    Task<IEnumerable<LoanResponse>> GetLoansByBorrowerNameAsync(string borrowerName);

    /// <summary>
    /// Updates an existing loan
    /// </summary>
    Task<LoanResponse?> UpdateLoanAsync(Guid loanId, UpdateLoanRequest request);

    /// <summary>
    /// Deletes a loan
    /// </summary>
    Task<bool> DeleteLoanAsync(Guid loanId);
}
