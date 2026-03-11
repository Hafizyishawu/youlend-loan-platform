using Xunit;
using FluentAssertions;
using FluentValidation.TestHelper;
using LoanApi.DTOs;
using LoanApi.Validators;

namespace LoanApi.Tests.Unit.Validators;

public class CreateLoanRequestValidatorTests
{
    private readonly CreateLoanRequestValidator _validator;

    public CreateLoanRequestValidatorTests()
    {
        _validator = new CreateLoanRequestValidator();
    }

    [Fact]
    public void Validate_ValidRequest_PassesValidation()
    {
        // Arrange
        var request = new CreateLoanRequest
        {
            BorrowerName = "John Doe",
            RepaymentAmount = 15000m,
            FundingAmount = 10000m
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.Should().NotBeNull();
        result.IsValid.Should().BeTrue();
    }

    [Fact]
    public void Validate_EmptyBorrowerName_FailsValidation()
    {
        // Arrange
        var request = new CreateLoanRequest
        {
            BorrowerName = "",
            RepaymentAmount = 10000m,
            FundingAmount = 8000m
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.BorrowerName)
            .WithErrorMessage("Borrower name is required");
    }

    [Fact]
    public void Validate_BorrowerNameTooLong_FailsValidation()
    {
        // Arrange
        var request = new CreateLoanRequest
        {
            BorrowerName = new string('A', 101), // 101 characters
            RepaymentAmount = 10000m,
            FundingAmount = 8000m
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.BorrowerName)
            .WithErrorMessage("Borrower name cannot exceed 100 characters");
    }

    [Fact]
    public void Validate_NegativeRepaymentAmount_FailsValidation()
    {
        // Arrange
        var request = new CreateLoanRequest
        {
            BorrowerName = "John Doe",
            RepaymentAmount = -1000m,
            FundingAmount = 8000m
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.RepaymentAmount)
            .WithErrorMessage("Repayment amount must be greater than 0");
    }

    [Fact]
    public void Validate_ZeroRepaymentAmount_FailsValidation()
    {
        // Arrange
        var request = new CreateLoanRequest
        {
            BorrowerName = "John Doe",
            RepaymentAmount = 0m,
            FundingAmount = 8000m
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.RepaymentAmount);
    }

    [Fact]
    public void Validate_NegativeFundingAmount_FailsValidation()
    {
        // Arrange
        var request = new CreateLoanRequest
        {
            BorrowerName = "John Doe",
            RepaymentAmount = 10000m,
            FundingAmount = -5000m
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.FundingAmount)
            .WithErrorMessage("Funding amount must be greater than 0");
    }

    [Fact]
    public void Validate_RepaymentLessThanFunding_FailsValidation()
    {
        // Arrange
        var request = new CreateLoanRequest
        {
            BorrowerName = "John Doe",
            RepaymentAmount = 5000m,
            FundingAmount = 10000m
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x)
            .WithErrorMessage("Repayment amount must be greater than or equal to funding amount");
    }

    [Fact]
    public void Validate_RepaymentEqualsFunding_PassesValidation()
    {
        // Arrange
        var request = new CreateLoanRequest
        {
            BorrowerName = "John Doe",
            RepaymentAmount = 10000m,
            FundingAmount = 10000m
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.IsValid.Should().BeTrue();
    }

    [Fact]
    public void Validate_ExcessiveRepaymentAmount_FailsValidation()
    {
        // Arrange
        var request = new CreateLoanRequest
        {
            BorrowerName = "John Doe",
            RepaymentAmount = 1_000_000_001m, // Over 1 billion
            FundingAmount = 10000m
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.RepaymentAmount);
    }
}
