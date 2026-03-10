using Microsoft.AspNetCore.Mvc;
using LoanApi.DTOs;
using LoanApi.Services;

namespace LoanApi.Controllers;

/// <summary>
/// REST API controller for loan management
/// </summary>
[ApiController]
[Route("api/v1/[controller]")]
[Produces("application/json")]
public class LoansController : ControllerBase
{
    private readonly ILoanService _loanService;
    private readonly ILogger<LoansController> _logger;

    public LoansController(ILoanService loanService, ILogger<LoansController> logger)
    {
        _loanService = loanService ?? throw new ArgumentNullException(nameof(loanService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Creates a new loan
    /// </summary>
    /// <param name="request">Loan creation request</param>
    /// <returns>Created loan</returns>
    /// <response code="201">Loan created successfully</response>
    /// <response code="400">Invalid request</response>
    [HttpPost]
    [ProducesResponseType(typeof(LoanResponse), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<LoanResponse>> CreateLoan([FromBody] CreateLoanRequest request)
    {
        _logger.LogInformation("Creating new loan for borrower: {BorrowerName}", request.BorrowerName);

        var loan = await _loanService.CreateLoanAsync(request);

        _logger.LogInformation("Loan created successfully with ID: {LoanId}", loan.LoanId);

        return CreatedAtAction(
            nameof(GetLoanById),
            new { id = loan.LoanId },
            loan);
    }

    /// <summary>
    /// Gets all loans
    /// </summary>
    /// <returns>List of all loans</returns>
    /// <response code="200">Loans retrieved successfully</response>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<LoanResponse>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<LoanResponse>>> GetAllLoans()
    {
        _logger.LogInformation("Retrieving all loans");

        var loans = await _loanService.GetAllLoansAsync();

        _logger.LogInformation("Retrieved {Count} loans", loans.Count());

        return Ok(loans);
    }

    /// <summary>
    /// Gets a loan by ID
    /// </summary>
    /// <param name="id">Loan ID</param>
    /// <returns>Loan details</returns>
    /// <response code="200">Loan found</response>
    /// <response code="404">Loan not found</response>
    [HttpGet("{id}")]
    [ProducesResponseType(typeof(LoanResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<LoanResponse>> GetLoanById(Guid id)
    {
        _logger.LogInformation("Retrieving loan with ID: {LoanId}", id);

        var loan = await _loanService.GetLoanByIdAsync(id);

        if (loan == null)
        {
            _logger.LogWarning("Loan with ID {LoanId} not found", id);
            return NotFound(new ErrorResponse
            {
                Message = $"Loan with ID {id} not found",
                StatusCode = 404,
                CorrelationId = HttpContext.TraceIdentifier
            });
        }

        _logger.LogInformation("Loan with ID {LoanId} retrieved successfully", id);

        return Ok(loan);
    }

    /// <summary>
    /// Gets loans by borrower name (query parameter)
    /// </summary>
    /// <param name="borrowerName">Borrower name to search for</param>
    /// <returns>List of loans for the borrower</returns>
    /// <response code="200">Loans retrieved successfully</response>
    /// <response code="400">Invalid borrower name</response>
    [HttpGet("search")]
    [ProducesResponseType(typeof(IEnumerable<LoanResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<IEnumerable<LoanResponse>>> SearchLoansByBorrowerName(
        [FromQuery] string borrowerName)
    {
        if (string.IsNullOrWhiteSpace(borrowerName))
        {
            return BadRequest(new ErrorResponse
            {
                Message = "Borrower name is required",
                StatusCode = 400,
                CorrelationId = HttpContext.TraceIdentifier
            });
        }

        _logger.LogInformation("Searching loans for borrower: {BorrowerName}", borrowerName);

        var loans = await _loanService.GetLoansByBorrowerNameAsync(borrowerName);

        _logger.LogInformation("Found {Count} loans for borrower: {BorrowerName}",
            loans.Count(), borrowerName);

        return Ok(loans);
    }

    /// <summary>
    /// Updates an existing loan
    /// </summary>
    /// <param name="id">Loan ID</param>
    /// <param name="request">Updated loan data</param>
    /// <returns>Updated loan</returns>
    /// <response code="200">Loan updated successfully</response>
    /// <response code="404">Loan not found</response>
    /// <response code="400">Invalid request</response>
    [HttpPut("{id}")]
    [ProducesResponseType(typeof(LoanResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<LoanResponse>> UpdateLoan(Guid id, [FromBody] UpdateLoanRequest request)
    {
        _logger.LogInformation("Updating loan with ID: {LoanId}", id);

        var loan = await _loanService.UpdateLoanAsync(id, request);

        if (loan == null)
        {
            _logger.LogWarning("Loan with ID {LoanId} not found for update", id);
            return NotFound(new ErrorResponse
            {
                Message = $"Loan with ID {id} not found",
                StatusCode = 404,
                CorrelationId = HttpContext.TraceIdentifier
            });
        }

        _logger.LogInformation("Loan with ID {LoanId} updated successfully", id);

        return Ok(loan);
    }

    /// <summary>
    /// Deletes a loan
    /// </summary>
    /// <param name="id">Loan ID</param>
    /// <returns>No content</returns>
    /// <response code="204">Loan deleted successfully</response>
    /// <response code="404">Loan not found</response>
    [HttpDelete("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteLoan(Guid id)
    {
        _logger.LogInformation("Deleting loan with ID: {LoanId}", id);

        var deleted = await _loanService.DeleteLoanAsync(id);

        if (!deleted)
        {
            _logger.LogWarning("Loan with ID {LoanId} not found for deletion", id);
            return NotFound(new ErrorResponse
            {
                Message = $"Loan with ID {id} not found",
                StatusCode = 404,
                CorrelationId = HttpContext.TraceIdentifier
            });
        }

        _logger.LogInformation("Loan with ID {LoanId} deleted successfully", id);

        return NoContent();
    }
}
