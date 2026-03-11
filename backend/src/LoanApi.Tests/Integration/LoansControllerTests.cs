using Xunit;
using System.Net;
using System.Net.Http.Json;
using FluentAssertions;
using LoanApi.DTOs;
using LoanApi.Tests.TestFixtures;
using Microsoft.AspNetCore.Mvc.Testing;

namespace LoanApi.Tests.Integration;

public class LoansControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public LoansControllerTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task CreateLoan_ValidRequest_ReturnsCreated()
    {
        // Arrange
        var request = LoanTestData.CreateValidCreateRequest();

        // Act
        var response = await _client.PostAsJsonAsync("/api/v1/loans", request);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        
        var loan = await response.Content.ReadFromJsonAsync<LoanResponse>();
        loan.Should().NotBeNull();
        loan!.LoanId.Should().NotBeEmpty();
        loan.BorrowerName.Should().Be(request.BorrowerName);
        loan.RepaymentAmount.Should().Be(request.RepaymentAmount);
        loan.FundingAmount.Should().Be(request.FundingAmount);
        
        response.Headers.Location.Should().NotBeNull();
    }

    [Fact]
    public async Task CreateLoan_InvalidRequest_ReturnsBadRequest()
    {
        // Arrange
        var request = LoanTestData.CreateInvalidCreateRequest_EmptyBorrowerName();

        // Act
        var response = await _client.PostAsJsonAsync("/api/v1/loans", request);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task GetAllLoans_NoLoans_ReturnsEmptyList()
    {
        // Act
        var response = await _client.GetAsync("/api/v1/loans");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        
        var loans = await response.Content.ReadFromJsonAsync<List<LoanResponse>>();
        loans.Should().NotBeNull();
    }

    [Fact]
    public async Task GetAllLoans_AfterCreating_ReturnsLoans()
    {
        // Arrange - Create a loan first
        var createRequest = LoanTestData.CreateValidCreateRequest();
        await _client.PostAsJsonAsync("/api/v1/loans", createRequest);

        // Act
        var response = await _client.GetAsync("/api/v1/loans");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        
        var loans = await response.Content.ReadFromJsonAsync<List<LoanResponse>>();
        loans.Should().NotBeNull();
        loans.Should().NotBeEmpty();
    }

    [Fact]
    public async Task GetLoanById_ExistingLoan_ReturnsLoan()
    {
        // Arrange - Create a loan first
        var createRequest = LoanTestData.CreateValidCreateRequest();
        var createResponse = await _client.PostAsJsonAsync("/api/v1/loans", createRequest);
        var createdLoan = await createResponse.Content.ReadFromJsonAsync<LoanResponse>();

        // Act
        var response = await _client.GetAsync($"/api/v1/loans/{createdLoan!.LoanId}");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        
        var loan = await response.Content.ReadFromJsonAsync<LoanResponse>();
        loan.Should().NotBeNull();
        loan!.LoanId.Should().Be(createdLoan.LoanId);
    }

    [Fact]
    public async Task GetLoanById_NonExistingLoan_ReturnsNotFound()
    {
        // Arrange
        var nonExistingId = Guid.NewGuid();

        // Act
        var response = await _client.GetAsync($"/api/v1/loans/{nonExistingId}");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task SearchLoansByBorrowerName_ExistingBorrower_ReturnsLoans()
    {
        // Arrange - Create a loan
        var createRequest = LoanTestData.CreateValidCreateRequest();
        createRequest.BorrowerName = "Integration Test User";
        await _client.PostAsJsonAsync("/api/v1/loans", createRequest);

        // Act
        var response = await _client.GetAsync($"/api/v1/loans/search?borrowerName=Integration Test User");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        
        var loans = await response.Content.ReadFromJsonAsync<List<LoanResponse>>();
        loans.Should().NotBeNull();
        loans.Should().NotBeEmpty();
        loans!.Should().AllSatisfy(l => l.BorrowerName.Should().Be("Integration Test User"));
    }

    [Fact]
    public async Task SearchLoansByBorrowerName_EmptyName_ReturnsBadRequest()
    {
        // Act
        var response = await _client.GetAsync("/api/v1/loans/search?borrowerName=");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task UpdateLoan_ExistingLoan_ReturnsUpdatedLoan()
    {
        // Arrange - Create a loan first
        var createRequest = LoanTestData.CreateValidCreateRequest();
        var createResponse = await _client.PostAsJsonAsync("/api/v1/loans", createRequest);
        var createdLoan = await createResponse.Content.ReadFromJsonAsync<LoanResponse>();

        var updateRequest = new UpdateLoanRequest
        {
            BorrowerName = "Updated Name",
            RepaymentAmount = 50000m,
            FundingAmount = 40000m
        };

        // Act
        var response = await _client.PutAsJsonAsync($"/api/v1/loans/{createdLoan!.LoanId}", updateRequest);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        
        var updatedLoan = await response.Content.ReadFromJsonAsync<LoanResponse>();
        updatedLoan.Should().NotBeNull();
        updatedLoan!.BorrowerName.Should().Be("Updated Name");
        updatedLoan.RepaymentAmount.Should().Be(50000m);
        updatedLoan.FundingAmount.Should().Be(40000m);
    }

    [Fact]
    public async Task UpdateLoan_NonExistingLoan_ReturnsNotFound()
    {
        // Arrange
        var nonExistingId = Guid.NewGuid();
        var updateRequest = LoanTestData.CreateValidUpdateRequest();

        // Act
        var response = await _client.PutAsJsonAsync($"/api/v1/loans/{nonExistingId}", updateRequest);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task DeleteLoan_ExistingLoan_ReturnsNoContent()
    {
        // Arrange - Create a loan first
        var createRequest = LoanTestData.CreateValidCreateRequest();
        var createResponse = await _client.PostAsJsonAsync("/api/v1/loans", createRequest);
        var createdLoan = await createResponse.Content.ReadFromJsonAsync<LoanResponse>();

        // Act
        var response = await _client.DeleteAsync($"/api/v1/loans/{createdLoan!.LoanId}");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NoContent);
        
        // Verify it's actually deleted
        var getResponse = await _client.GetAsync($"/api/v1/loans/{createdLoan.LoanId}");
        getResponse.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task DeleteLoan_NonExistingLoan_ReturnsNotFound()
    {
        // Arrange
        var nonExistingId = Guid.NewGuid();

        // Act
        var response = await _client.DeleteAsync($"/api/v1/loans/{nonExistingId}");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task HealthCheck_Live_ReturnsHealthy()
    {
        // Act
        var response = await _client.GetAsync("/health/live");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task HealthCheck_Ready_ReturnsHealthy()
    {
        // Act
        var response = await _client.GetAsync("/health/ready");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }
}
