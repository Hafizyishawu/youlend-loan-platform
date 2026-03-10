using System.Collections.Concurrent;
using LoanApi.Models;

namespace LoanApi.Repositories;

/// <summary>
/// Thread-safe in-memory implementation of loan repository using ConcurrentDictionary
/// </summary>
public class InMemoryLoanRepository : ILoanRepository
{
    private readonly ConcurrentDictionary<Guid, Loan> _loans = new();

    public Task<Loan> CreateAsync(Loan loan)
    {
        if (loan == null)
            throw new ArgumentNullException(nameof(loan));

        loan.LoanId = Guid.NewGuid();
        loan.CreatedAt = DateTime.UtcNow;
        loan.UpdatedAt = DateTime.UtcNow;

        if (!_loans.TryAdd(loan.LoanId, loan))
        {
            throw new InvalidOperationException($"Failed to add loan with ID {loan.LoanId}");
        }

        return Task.FromResult(loan);
    }

    public Task<Loan?> GetByIdAsync(Guid loanId)
    {
        _loans.TryGetValue(loanId, out var loan);
        return Task.FromResult(loan);
    }

    public Task<IEnumerable<Loan>> GetAllAsync()
    {
        var loans = _loans.Values.OrderByDescending(l => l.CreatedAt).ToList();
        return Task.FromResult<IEnumerable<Loan>>(loans);
    }

    public Task<IEnumerable<Loan>> GetByBorrowerNameAsync(string borrowerName)
    {
        if (string.IsNullOrWhiteSpace(borrowerName))
        {
            return Task.FromResult<IEnumerable<Loan>>(new List<Loan>());
        }

        var loans = _loans.Values
            .Where(l => l.BorrowerName.Equals(borrowerName, StringComparison.OrdinalIgnoreCase))
            .OrderByDescending(l => l.CreatedAt)
            .ToList();

        return Task.FromResult<IEnumerable<Loan>>(loans);
    }

    public Task<Loan?> UpdateAsync(Loan loan)
    {
        if (loan == null)
            throw new ArgumentNullException(nameof(loan));

        if (!_loans.ContainsKey(loan.LoanId))
        {
            return Task.FromResult<Loan?>(null);
        }

        loan.UpdatedAt = DateTime.UtcNow;

        _loans[loan.LoanId] = loan;
        return Task.FromResult<Loan?>(loan);
    }

    public Task<bool> DeleteAsync(Guid loanId)
    {
        var result = _loans.TryRemove(loanId, out _);
        return Task.FromResult(result);
    }

    public Task<bool> ExistsAsync(Guid loanId)
    {
        var exists = _loans.ContainsKey(loanId);
        return Task.FromResult(exists);
    }
}
