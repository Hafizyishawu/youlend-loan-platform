using LoanApi.DTOs;
using LoanApi.Models;

namespace LoanApi.Tests.TestFixtures;

/// <summary>
/// Factory for creating test data
/// </summary>
public static class LoanTestData
{
    public static Loan CreateValidLoan()
    {
        return new Loan
        {
            LoanId = Guid.NewGuid(),
            BorrowerName = "John Doe",
            RepaymentAmount = 15000m,
            FundingAmount = 10000m,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
    }

    public static List<Loan> CreateMultipleLoans(int count)
    {
        var loans = new List<Loan>();
        for (int i = 0; i < count; i++)
        {
            loans.Add(new Loan
            {
                LoanId = Guid.NewGuid(),
                BorrowerName = $"Borrower {i + 1}",
                RepaymentAmount = 10000m + (i * 1000),
                FundingAmount = 8000m + (i * 800),
                CreatedAt = DateTime.UtcNow.AddDays(-i),
                UpdatedAt = DateTime.UtcNow.AddDays(-i)
            });
        }
        return loans;
    }

    public static CreateLoanRequest CreateValidCreateRequest()
    {
        return new CreateLoanRequest
        {
            BorrowerName = "Jane Smith",
            RepaymentAmount = 20000m,
            FundingAmount = 15000m
        };
    }

    public static UpdateLoanRequest CreateValidUpdateRequest()
    {
        return new UpdateLoanRequest
        {
            BorrowerName = "Jane Smith Updated",
            RepaymentAmount = 25000m,
            FundingAmount = 18000m
        };
    }

    public static CreateLoanRequest CreateInvalidCreateRequest_EmptyBorrowerName()
    {
        return new CreateLoanRequest
        {
            BorrowerName = "",
            RepaymentAmount = 10000m,
            FundingAmount = 8000m
        };
    }

    public static CreateLoanRequest CreateInvalidCreateRequest_NegativeAmount()
    {
        return new CreateLoanRequest
        {
            BorrowerName = "John Doe",
            RepaymentAmount = -1000m,
            FundingAmount = 8000m
        };
    }

    public static CreateLoanRequest CreateInvalidCreateRequest_RepaymentLessThanFunding()
    {
        return new CreateLoanRequest
        {
            BorrowerName = "John Doe",
            RepaymentAmount = 5000m,
            FundingAmount = 10000m
        };
    }
}
