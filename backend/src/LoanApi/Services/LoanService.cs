using LoanApi.DTOs;
using LoanApi.Models;
using LoanApi.Repositories;

namespace LoanApi.Services;

/// <summary>
/// Service implementation for loan business logic
/// </summary>
public class LoanService : ILoanService
{
    private readonly ILoanRepository _repository;

    public LoanService(ILoanRepository repository)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
    }

    public async Task<LoanResponse> CreateLoanAsync(CreateLoanRequest request)
    {
        if (request == null)
            throw new ArgumentNullException(nameof(request));

        var loan = new Loan
        {
            BorrowerName = request.BorrowerName.Trim(),
            RepaymentAmount = request.RepaymentAmount,
            FundingAmount = request.FundingAmount
        };

        var createdLoan = await _repository.CreateAsync(loan);
        return MapToResponse(createdLoan);
    }

    public async Task<LoanResponse?> GetLoanByIdAsync(Guid loanId)
    {
        var loan = await _repository.GetByIdAsync(loanId);
        return loan != null ? MapToResponse(loan) : null;
    }

    public async Task<IEnumerable<LoanResponse>> GetAllLoansAsync()
    {
        var loans = await _repository.GetAllAsync();
        return loans.Select(MapToResponse);
    }

    public async Task<IEnumerable<LoanResponse>> GetLoansByBorrowerNameAsync(string borrowerName)
    {
        if (string.IsNullOrWhiteSpace(borrowerName))
        {
            return Enumerable.Empty<LoanResponse>();
        }

        var loans = await _repository.GetByBorrowerNameAsync(borrowerName.Trim());
        return loans.Select(MapToResponse);
    }

    public async Task<LoanResponse?> UpdateLoanAsync(Guid loanId, UpdateLoanRequest request)
    {
        if (request == null)
            throw new ArgumentNullException(nameof(request));

        var existingLoan = await _repository.GetByIdAsync(loanId);
        if (existingLoan == null)
        {
            return null;
        }

        existingLoan.BorrowerName = request.BorrowerName.Trim();
        existingLoan.RepaymentAmount = request.RepaymentAmount;
        existingLoan.FundingAmount = request.FundingAmount;

        var updatedLoan = await _repository.UpdateAsync(existingLoan);
        return updatedLoan != null ? MapToResponse(updatedLoan) : null;
    }

    public async Task<bool> DeleteLoanAsync(Guid loanId)
    {
        return await _repository.DeleteAsync(loanId);
    }

    private static LoanResponse MapToResponse(Loan loan)
    {
        return new LoanResponse
        {
            LoanId = loan.LoanId,
            BorrowerName = loan.BorrowerName,
            RepaymentAmount = loan.RepaymentAmount,
            FundingAmount = loan.FundingAmount,
            CreatedAt = loan.CreatedAt,
            UpdatedAt = loan.UpdatedAt
        };
    }
}
