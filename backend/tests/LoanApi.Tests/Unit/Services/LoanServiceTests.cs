using Xunit;
using FluentAssertions;
using LoanApi.Models;
using LoanApi.Repositories;
using LoanApi.Services;
using LoanApi.Tests.TestFixtures;
using Moq;

namespace LoanApi.Tests.Unit.Services;

public class LoanServiceTests
{
    private readonly Mock<ILoanRepository> _repositoryMock;
    private readonly LoanService _service;

    public LoanServiceTests()
    {
        _repositoryMock = new Mock<ILoanRepository>();
        _service = new LoanService(_repositoryMock.Object);
    }

    [Fact]
    public async Task CreateLoanAsync_ValidRequest_ReturnsLoanResponse()
    {
        // Arrange
        var request = LoanTestData.CreateValidCreateRequest();
        var createdLoan = LoanTestData.CreateValidLoan();

        _repositoryMock
            .Setup(r => r.CreateAsync(It.IsAny<Loan>()))
            .ReturnsAsync(createdLoan);

        // Act
        var result = await _service.CreateLoanAsync(request);

        // Assert
        result.Should().NotBeNull();
        result.LoanId.Should().Be(createdLoan.LoanId);
        result.BorrowerName.Should().Be(createdLoan.BorrowerName);
        result.RepaymentAmount.Should().Be(createdLoan.RepaymentAmount);
        result.FundingAmount.Should().Be(createdLoan.FundingAmount);

        _repositoryMock.Verify(r => r.CreateAsync(It.IsAny<Loan>()), Times.Once);
    }

    [Fact]
    public async Task CreateLoanAsync_NullRequest_ThrowsArgumentNullException()
    {
        // Act
        Func<Task> act = async () => await _service.CreateLoanAsync(null!);

        // Assert
        await act.Should().ThrowAsync<ArgumentNullException>();
    }

    [Fact]
    public async Task CreateLoanAsync_TrimsBorrowerName()
    {
        // Arrange
        var request = LoanTestData.CreateValidCreateRequest();
        request.BorrowerName = "  John Doe  ";

        var createdLoan = LoanTestData.CreateValidLoan();
        createdLoan.BorrowerName = "John Doe";

        _repositoryMock
            .Setup(r => r.CreateAsync(It.Is<Loan>(l => l.BorrowerName == "John Doe")))
            .ReturnsAsync(createdLoan);

        // Act
        var result = await _service.CreateLoanAsync(request);

        // Assert
        result.BorrowerName.Should().Be("John Doe");
        _repositoryMock.Verify(
            r => r.CreateAsync(It.Is<Loan>(l => l.BorrowerName == "John Doe")),
            Times.Once);
    }

    [Fact]
    public async Task GetLoanByIdAsync_ExistingLoan_ReturnsLoanResponse()
    {
        // Arrange
        var loan = LoanTestData.CreateValidLoan();
        var loanId = loan.LoanId;

        _repositoryMock
            .Setup(r => r.GetByIdAsync(loanId))
            .ReturnsAsync(loan);

        // Act
        var result = await _service.GetLoanByIdAsync(loanId);

        // Assert
        result.Should().NotBeNull();
        result!.LoanId.Should().Be(loanId);
        result.BorrowerName.Should().Be(loan.BorrowerName);
    }

    [Fact]
    public async Task GetLoanByIdAsync_NonExistingLoan_ReturnsNull()
    {
        // Arrange
        var loanId = Guid.NewGuid();

        _repositoryMock
            .Setup(r => r.GetByIdAsync(loanId))
            .ReturnsAsync((Loan?)null);

        // Act
        var result = await _service.GetLoanByIdAsync(loanId);

        // Assert
        result.Should().BeNull();
    }

    [Fact]
    public async Task GetAllLoansAsync_MultipleLoans_ReturnsAllLoanResponses()
    {
        // Arrange
        var loans = LoanTestData.CreateMultipleLoans(5);

        _repositoryMock
            .Setup(r => r.GetAllAsync())
            .ReturnsAsync(loans);

        // Act
        var result = await _service.GetAllLoansAsync();

        // Assert
        result.Should().HaveCount(5);
        result.Should().AllSatisfy(r => r.Should().NotBeNull());
    }

    [Fact]
    public async Task GetAllLoansAsync_NoLoans_ReturnsEmptyList()
    {
        // Arrange
        _repositoryMock
            .Setup(r => r.GetAllAsync())
            .ReturnsAsync(new List<Loan>());

        // Act
        var result = await _service.GetAllLoansAsync();

        // Assert
        result.Should().BeEmpty();
    }

    [Fact]
    public async Task GetLoansByBorrowerNameAsync_ExistingBorrower_ReturnsLoans()
    {
        // Arrange
        var borrowerName = "John Doe";
        var loans = new List<Loan>
        {
            LoanTestData.CreateValidLoan(),
            LoanTestData.CreateValidLoan()
        };

        _repositoryMock
            .Setup(r => r.GetByBorrowerNameAsync(borrowerName))
            .ReturnsAsync(loans);

        // Act
        var result = await _service.GetLoansByBorrowerNameAsync(borrowerName);

        // Assert
        result.Should().HaveCount(2);
    }

    [Fact]
    public async Task GetLoansByBorrowerNameAsync_EmptyName_ReturnsEmpty()
    {
        // Act
        var result = await _service.GetLoansByBorrowerNameAsync("");

        // Assert
        result.Should().BeEmpty();
        _repositoryMock.Verify(r => r.GetByBorrowerNameAsync(It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public async Task GetLoansByBorrowerNameAsync_TrimsBorrowerName()
    {
        // Arrange
        var loans = new List<Loan> { LoanTestData.CreateValidLoan() };

        _repositoryMock
            .Setup(r => r.GetByBorrowerNameAsync("John Doe"))
            .ReturnsAsync(loans);

        // Act
        var result = await _service.GetLoansByBorrowerNameAsync("  John Doe  ");

        // Assert
        result.Should().HaveCount(1);
        _repositoryMock.Verify(r => r.GetByBorrowerNameAsync("John Doe"), Times.Once);
    }

    [Fact]
    public async Task UpdateLoanAsync_ExistingLoan_ReturnsUpdatedLoanResponse()
    {
        // Arrange
        var loanId = Guid.NewGuid();
        var existingLoan = LoanTestData.CreateValidLoan();
        existingLoan.LoanId = loanId;

        var updateRequest = LoanTestData.CreateValidUpdateRequest();

        _repositoryMock
            .Setup(r => r.GetByIdAsync(loanId))
            .ReturnsAsync(existingLoan);

        _repositoryMock
            .Setup(r => r.UpdateAsync(It.IsAny<Loan>()))
            .ReturnsAsync(existingLoan);

        // Act
        var result = await _service.UpdateLoanAsync(loanId, updateRequest);

        // Assert
        result.Should().NotBeNull();
        result!.BorrowerName.Should().Be(updateRequest.BorrowerName);
        result.RepaymentAmount.Should().Be(updateRequest.RepaymentAmount);
        result.FundingAmount.Should().Be(updateRequest.FundingAmount);

        _repositoryMock.Verify(r => r.UpdateAsync(It.IsAny<Loan>()), Times.Once);
    }

    [Fact]
    public async Task UpdateLoanAsync_NonExistingLoan_ReturnsNull()
    {
        // Arrange
        var loanId = Guid.NewGuid();
        var updateRequest = LoanTestData.CreateValidUpdateRequest();

        _repositoryMock
            .Setup(r => r.GetByIdAsync(loanId))
            .ReturnsAsync((Loan?)null);

        // Act
        var result = await _service.UpdateLoanAsync(loanId, updateRequest);

        // Assert
        result.Should().BeNull();
        _repositoryMock.Verify(r => r.UpdateAsync(It.IsAny<Loan>()), Times.Never);
    }

    [Fact]
    public async Task UpdateLoanAsync_NullRequest_ThrowsArgumentNullException()
    {
        // Arrange
        var loanId = Guid.NewGuid();

        // Act
        Func<Task> act = async () => await _service.UpdateLoanAsync(loanId, null!);

        // Assert
        await act.Should().ThrowAsync<ArgumentNullException>();
    }

    [Fact]
    public async Task DeleteLoanAsync_ExistingLoan_ReturnsTrue()
    {
        // Arrange
        var loanId = Guid.NewGuid();

        _repositoryMock
            .Setup(r => r.DeleteAsync(loanId))
            .ReturnsAsync(true);

        // Act
        var result = await _service.DeleteLoanAsync(loanId);

        // Assert
        result.Should().BeTrue();
        _repositoryMock.Verify(r => r.DeleteAsync(loanId), Times.Once);
    }

    [Fact]
    public async Task DeleteLoanAsync_NonExistingLoan_ReturnsFalse()
    {
        // Arrange
        var loanId = Guid.NewGuid();

        _repositoryMock
            .Setup(r => r.DeleteAsync(loanId))
            .ReturnsAsync(false);

        // Act
        var result = await _service.DeleteLoanAsync(loanId);

        // Assert
        result.Should().BeFalse();
    }
}
