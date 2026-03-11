# API Documentation

YouLend Loan Management API - Complete REST API Reference

## Base URL

- **Local Development:** http://localhost:8080/api/v1
- **Live Demo:** https://youlend.certifiles.com/api/v1

## Authentication

This API currently uses in-memory storage and does not require authentication for demonstration purposes. In production, it would integrate with Auth0 JWT tokens.

## Endpoints

### Create Loan
**POST** `/api/v1/loans`

Creates a new loan record.

**Request Body:**
```json
{
  "borrowerName": "John Doe",
  "fundingAmount": 50000.00,
  "repaymentAmount": 55000.00
}
```

**Validation Rules:**
- `borrowerName`: Required, max 100 characters
- `fundingAmount`: Required, £0.01 - £1,000,000,000
- `repaymentAmount`: Required, £0.01 - £1,000,000,000, must be ≥ fundingAmount

**Response (201 Created):**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "borrowerName": "John Doe",
  "fundingAmount": 50000.00,
  "repaymentAmount": 55000.00,
  "createdAt": "2026-03-10T14:30:00Z"
}
```

### Get All Loans
**GET** `/api/v1/loans`

Retrieves all loans.

**Response (200 OK):**
```json
[
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "borrowerName": "John Doe",
    "fundingAmount": 50000.00,
    "repaymentAmount": 55000.00,
    "createdAt": "2026-03-10T14:30:00Z"
  }
]
```

### Get Loan by ID
**GET** `/api/v1/loans/{id}`

Retrieves a specific loan by ID.

**Response (200 OK):**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "borrowerName": "John Doe",
  "fundingAmount": 50000.00,
  "repaymentAmount": 55000.00,
  "createdAt": "2026-03-10T14:30:00Z"
}
```

**Error Response (404 Not Found):**
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.4",
  "title": "Not Found",
  "status": 404,
  "detail": "Loan with ID 123e4567-e89b-12d3-a456-426614174000 was not found."
}
```

### Search Loans by Borrower
**GET** `/api/v1/loans/search?borrowerName={name}`

Searches for loans by borrower name (case-insensitive, partial match).

**Example:** `/api/v1/loans/search?borrowerName=john`

**Response (200 OK):**
```json
[
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "borrowerName": "John Doe",
    "fundingAmount": 50000.00,
    "repaymentAmount": 55000.00,
    "createdAt": "2026-03-10T14:30:00Z"
  }
]
```

### Update Loan
**PUT** `/api/v1/loans/{id}`

Updates an existing loan.

**Request Body:**
```json
{
  "borrowerName": "John Smith",
  "fundingAmount": 60000.00,
  "repaymentAmount": 66000.00
}
```

**Response (200 OK):**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "borrowerName": "John Smith",
  "fundingAmount": 60000.00,
  "repaymentAmount": 66000.00,
  "createdAt": "2026-03-10T14:30:00Z"
}
```

### Delete Loan
**DELETE** `/api/v1/loans/{id}`

Deletes a loan by ID.

**Response (204 No Content)**

**Error Response (404 Not Found):**
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.4",
  "title": "Not Found", 
  "status": 404,
  "detail": "Loan with ID 123e4567-e89b-12d3-a456-426614174000 was not found."
}
```

## Health Endpoints

### Liveness Probe
**GET** `/health/live`

Returns 200 if the application is running.

### Readiness Probe
**GET** `/health/ready`

Returns 200 if the application is ready to serve requests.

## Metrics Endpoint

### Prometheus Metrics
**GET** `/metrics`

Returns Prometheus-formatted metrics for monitoring.

## Error Responses

All API errors follow RFC 7231 Problem Details format:

```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "Validation Error",
  "status": 400,
  "detail": "Repayment amount must be greater than or equal to funding amount",
  "errors": {
    "RepaymentAmount": ["Repayment amount must be greater than or equal to funding amount"]
  }
}
```

## HTTP Status Codes

- **200 OK** - Successful GET, PUT
- **201 Created** - Successful POST
- **204 No Content** - Successful DELETE
- **400 Bad Request** - Validation errors
- **404 Not Found** - Resource not found
- **500 Internal Server Error** - Server errors

## Testing the API

### Using curl

```bash
# Create a loan
curl -X POST "https://youlend.certifiles.com/api/v1/loans" \
  -H "Content-Type: application/json" \
  -d '{"borrowerName":"Jane Doe","fundingAmount":25000,"repaymentAmount":27500}'

# Get all loans
curl "https://youlend.certifiles.com/api/v1/loans"

# Search by borrower
curl "https://youlend.certifiles.com/api/v1/loans/search?borrowerName=jane"
```

### Using Swagger UI (Development Only)

When running locally in Development mode:
- Start the API: `dotnet run`
- Visit: http://localhost:8080/swagger
- Interactive API documentation with try-it-now functionality

## Business Rules

1. **Loan Validation**: Repayment amount must be ≥ funding amount
2. **Currency**: All amounts in GBP (£)
3. **Precision**: Decimal amounts supported to 2 decimal places
4. **Name Validation**: Borrower names required, max 100 characters
5. **Amount Limits**: £0.01 minimum, £1,000,000,000 maximum

## Data Storage

Currently uses thread-safe in-memory storage (ConcurrentDictionary). Data persists during application runtime but is lost on restart. Future versions will implement persistent database storage.