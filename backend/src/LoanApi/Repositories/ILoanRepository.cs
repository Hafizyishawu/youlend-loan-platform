using LoanApi.Models;

namespace LoanApi.Repositories;

/// <summary>
/// Repository interface for loan data access
/// </summary>
public interface ILoanRepository
{
    /// <summary>
    /// Creates a new loan
    /// </summary>
    Task<Loan> CreateAsync(Loan loan);

    /// <summary>
    /// Gets a loan by ID
    /// </summary>
    Task<Loan?> GetByIdAsync(Guid loanId);

    /// <summary>
    /// Gets all loans
    /// </summary>
    Task<IEnumerable<Loan>> GetAllAsync();

    /// <summary>
    /// Gets loans by borrower name
    /// </summary>
    Task<IEnumerable<Loan>> GetByBorrowerNameAsync(string borrowerName);

    /// <summary>
    /// Updates an existing loan
    /// </summary>
    Task<Loan?> UpdateAsync(Loan loan);

    /// <summary>
    /// Deletes a loan by ID
    /// </summary>
    Task<bool> DeleteAsync(Guid loanId);

    /// <summary>
    /// Checks if a loan exists
    /// </summary>
    Task<bool> ExistsAsync(Guid loanId);
}
