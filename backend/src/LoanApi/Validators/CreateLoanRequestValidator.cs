using FluentValidation;
using LoanApi.DTOs;

namespace LoanApi.Validators;

/// <summary>
/// Validator for CreateLoanRequest
/// </summary>
public class CreateLoanRequestValidator : AbstractValidator<CreateLoanRequest>
{
    public CreateLoanRequestValidator()
    {
        RuleFor(x => x.BorrowerName)
            .NotEmpty()
            .WithMessage("Borrower name is required")
            .MinimumLength(1)
            .WithMessage("Borrower name must be at least 1 character")
            .MaximumLength(100)
            .WithMessage("Borrower name cannot exceed 100 characters");

        RuleFor(x => x.RepaymentAmount)
            .GreaterThan(0)
            .WithMessage("Repayment amount must be greater than 0")
            .LessThanOrEqualTo(1_000_000_000)
            .WithMessage("Repayment amount cannot exceed 1,000,000,000");

        RuleFor(x => x.FundingAmount)
            .GreaterThan(0)
            .WithMessage("Funding amount must be greater than 0")
            .LessThanOrEqualTo(1_000_000_000)
            .WithMessage("Funding amount cannot exceed 1,000,000,000");

        RuleFor(x => x)
            .Must(x => x.RepaymentAmount >= x.FundingAmount)
            .WithMessage("Repayment amount must be greater than or equal to funding amount")
            .When(x => x.RepaymentAmount > 0 && x.FundingAmount > 0);
    }
}
