using Xunit;
using FluentAssertions;
using FluentValidation.TestHelper;
using LoanApi.DTOs;
using LoanApi.Validators;

namespace LoanApi.Tests.Unit.Validators;

public class UpdateLoanRequestValidatorTests
{
    private readonly UpdateLoanRequestValidator _validator;

    public UpdateLoanRequestValidatorTests()
    {
        _validator = new UpdateLoanRequestValidator();
    }

    [Fact]
    public void Validate_ValidRequest_PassesValidation()
    {
        // Arrange
        var request = new UpdateLoanRequest
        {
            BorrowerName = "Jane Smith",
            RepaymentAmount = 20000m,
            FundingAmount = 15000m
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.IsValid.Should().BeTrue();
    }

    [Fact]
    public void Validate_EmptyBorrowerName_FailsValidation()
    {
        // Arrange
        var request = new UpdateLoanRequest
        {
            BorrowerName = "",
            RepaymentAmount = 10000m,
            FundingAmount = 8000m
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.BorrowerName);
    }

    [Fact]
    public void Validate_RepaymentLessThanFunding_FailsValidation()
    {
        // Arrange
        var request = new UpdateLoanRequest
        {
            BorrowerName = "Jane Smith",
            RepaymentAmount = 5000m,
            FundingAmount = 10000m
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x);
    }

    [Fact]
    public void Validate_NegativeAmounts_FailsValidation()
    {
        // Arrange
        var request = new UpdateLoanRequest
        {
            BorrowerName = "Jane Smith",
            RepaymentAmount = -1000m,
            FundingAmount = -500m
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.ShouldHaveValidationErrorFor(x => x.RepaymentAmount);
        result.ShouldHaveValidationErrorFor(x => x.FundingAmount);
    }

    [Fact]
    public void Validate_BorrowerNameMaxLength_PassesValidation()
    {
        // Arrange
        var request = new UpdateLoanRequest
        {
            BorrowerName = new string('A', 100), // Exactly 100 characters
            RepaymentAmount = 10000m,
            FundingAmount = 8000m
        };

        // Act
        var result = _validator.TestValidate(request);

        // Assert
        result.IsValid.Should().BeTrue();
    }
}
