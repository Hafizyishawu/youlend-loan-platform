using Xunit;
using FluentAssertions;
using LoanApi.Models;
using LoanApi.Repositories;
using LoanApi.Tests.TestFixtures;

namespace LoanApi.Tests.Unit.Repositories;

public class InMemoryLoanRepositoryTests
{
    private readonly InMemoryLoanRepository _repository;

    public InMemoryLoanRepositoryTests()
    {
        _repository = new InMemoryLoanRepository();
    }

    [Fact]
    public async Task CreateAsync_ValidLoan_ReturnsLoanWithId()
    {
        // Arrange
        var loan = LoanTestData.CreateValidLoan();
        loan.LoanId = Guid.Empty; // Should be assigned by repository

        // Act
        var result = await _repository.CreateAsync(loan);

        // Assert
        result.Should().NotBeNull();
        result.LoanId.Should().NotBeEmpty();
        result.BorrowerName.Should().Be(loan.BorrowerName);
        result.CreatedAt.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromSeconds(1));
        result.UpdatedAt.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromSeconds(1));
    }

    [Fact]
    public async Task CreateAsync_NullLoan_ThrowsArgumentNullException()
    {
        // Act
        Func<Task> act = async () => await _repository.CreateAsync(null!);

        // Assert
        await act.Should().ThrowAsync<ArgumentNullException>();
    }

    [Fact]
    public async Task GetByIdAsync_ExistingLoan_ReturnsLoan()
    {
        // Arrange
        var loan = LoanTestData.CreateValidLoan();
        var created = await _repository.CreateAsync(loan);

        // Act
        var result = await _repository.GetByIdAsync(created.LoanId);

        // Assert
        result.Should().NotBeNull();
        result!.LoanId.Should().Be(created.LoanId);
        result.BorrowerName.Should().Be(created.BorrowerName);
    }

    [Fact]
    public async Task GetByIdAsync_NonExistingLoan_ReturnsNull()
    {
        // Arrange
        var nonExistingId = Guid.NewGuid();

        // Act
        var result = await _repository.GetByIdAsync(nonExistingId);

        // Assert
        result.Should().BeNull();
    }

    [Fact]
    public async Task GetAllAsync_MultipleLoans_ReturnsAllInDescendingOrder()
    {
        // Arrange
        var loans = LoanTestData.CreateMultipleLoans(5);
        foreach (var loan in loans)
        {
            await _repository.CreateAsync(loan);
        }

        // Act
        var result = await _repository.GetAllAsync();

        // Assert
        result.Should().HaveCount(5);
        result.Should().BeInDescendingOrder(l => l.CreatedAt);
    }

    [Fact]
    public async Task GetAllAsync_NoLoans_ReturnsEmptyList()
    {
        // Act
        var result = await _repository.GetAllAsync();

        // Assert
        result.Should().BeEmpty();
    }

    [Fact]
    public async Task GetByBorrowerNameAsync_ExistingBorrower_ReturnsLoans()
    {
        // Arrange
        var borrowerName = "John Doe";
        var loan1 = LoanTestData.CreateValidLoan();
        loan1.BorrowerName = borrowerName;
        var loan2 = LoanTestData.CreateValidLoan();
        loan2.BorrowerName = borrowerName;

        await _repository.CreateAsync(loan1);
        await _repository.CreateAsync(loan2);

        // Act
        var result = await _repository.GetByBorrowerNameAsync(borrowerName);

        // Assert
        result.Should().HaveCount(2);
        result.Should().AllSatisfy(l => l.BorrowerName.Should().Be(borrowerName));
    }

    [Fact]
    public async Task GetByBorrowerNameAsync_CaseInsensitive_ReturnsLoans()
    {
        // Arrange
        var loan = LoanTestData.CreateValidLoan();
        loan.BorrowerName = "John Doe";
        await _repository.CreateAsync(loan);

        // Act
        var result = await _repository.GetByBorrowerNameAsync("JOHN DOE");

        // Assert
        result.Should().HaveCount(1);
    }

    [Fact]
    public async Task UpdateAsync_ExistingLoan_UpdatesAndReturnsLoan()
    {
        // Arrange
        var loan = LoanTestData.CreateValidLoan();
        var created = await _repository.CreateAsync(loan);

        created.BorrowerName = "Updated Name";
        created.RepaymentAmount = 50000m;

        // Act
        var result = await _repository.UpdateAsync(created);

        // Assert
        result.Should().NotBeNull();
        result!.BorrowerName.Should().Be("Updated Name");
        result.RepaymentAmount.Should().Be(50000m);
        result.UpdatedAt.Should().BeAfter(result.CreatedAt);
    }

    [Fact]
    public async Task UpdateAsync_NonExistingLoan_ReturnsNull()
    {
        // Arrange
        var loan = LoanTestData.CreateValidLoan();

        // Act
        var result = await _repository.UpdateAsync(loan);

        // Assert
        result.Should().BeNull();
    }

    [Fact]
    public async Task DeleteAsync_ExistingLoan_ReturnsTrue()
    {
        // Arrange
        var loan = LoanTestData.CreateValidLoan();
        var created = await _repository.CreateAsync(loan);

        // Act
        var result = await _repository.DeleteAsync(created.LoanId);

        // Assert
        result.Should().BeTrue();

        // Verify it's actually deleted
        var deleted = await _repository.GetByIdAsync(created.LoanId);
        deleted.Should().BeNull();
    }

    [Fact]
    public async Task DeleteAsync_NonExistingLoan_ReturnsFalse()
    {
        // Arrange
        var nonExistingId = Guid.NewGuid();

        // Act
        var result = await _repository.DeleteAsync(nonExistingId);

        // Assert
        result.Should().BeFalse();
    }
}
