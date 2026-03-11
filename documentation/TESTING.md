# 🧪 Testing Guide

## Overview

This guide covers testing procedures for both backend and frontend components of the YouLend platform.

## 🔧 Backend Testing

### Running Tests
```bash
cd backend
dotnet test
```

### Test Coverage
- **55 passing tests** covering all API endpoints
- **Unit tests** for business logic and validation
- **Integration tests** for API endpoints
- **Repository tests** for data operations

### Test Structure
```
backend/tests/LoanApi.Tests/
├── Controllers/          # API endpoint tests
├── Services/            # Business logic tests
├── Repositories/        # Data access tests
├── Models/              # Model validation tests
└── Integration/         # End-to-end tests
```

### Key Test Scenarios
- ✅ Loan creation with valid data
- ✅ Business rule validation (repayment ≥ funding)
- ✅ Input validation for all fields
- ✅ Search functionality
- ✅ Error handling and edge cases
- ✅ Thread safety for concurrent operations

## 🎨 Frontend Testing

### Running Tests
```bash
cd frontend
npm test                 # Run once
npm run test:watch      # Watch mode
npm run test:coverage   # With coverage
```

### Test Coverage
- **Component tests** for all UI components
- **Service tests** for API integration
- **Integration tests** for user workflows
- **E2E tests** for complete user journeys

### Test Structure
```
frontend/src/app/
├── features/loans/      # Feature component tests
├── core/services/       # Service tests
├── shared/components/   # Shared component tests
└── guards/             # Authentication guard tests
```

### Key Test Scenarios
- ✅ Loan form validation
- ✅ API error handling
- ✅ Authentication flows
- ✅ Responsive design
- ✅ User input validation
- ✅ Navigation and routing

## 🚀 Running All Tests

### Local Development
```bash
# Root level - runs both backend and frontend tests
npm test

# Individual components
npm run test:backend
npm run test:frontend
```

### CI/CD Pipeline
Tests run automatically on:
- Pull requests
- Main branch pushes
- Release deployments

### Test Reports
- **Backend**: Coverage reports generated in `backend/TestResults/`
- **Frontend**: Coverage reports in `frontend/coverage/`
- **CI**: Test results visible in GitHub Actions

## 📊 Quality Gates

### Code Coverage Targets
- **Backend**: 95%+ line coverage
- **Frontend**: 90%+ line coverage
- **Critical paths**: 100% coverage

### Test Requirements
- All new features must include tests
- Bug fixes must include regression tests
- API changes must update integration tests
- UI changes must update component tests

## 🔧 Testing Tools

### Backend
- **xUnit**: Test framework
- **Moq**: Mocking framework
- **FluentAssertions**: Assertion library
- **WebApplicationFactory**: Integration testing

### Frontend
- **Jasmine**: Test framework
- **Karma**: Test runner
- **Protractor**: E2E testing
- **Angular Testing Utilities**: Component testing

## 🐛 Debugging Tests

### Backend
```bash
# Debug specific test
dotnet test --logger "console;verbosity=detailed" --filter "TestName"

# Debug with breakpoints
dotnet test --logger "console;verbosity=detailed" --collect:"XPlat Code Coverage"
```

### Frontend
```bash
# Debug in Chrome
npm run test:debug

# Specific test file
ng test --include="**/loan.component.spec.ts"
```

For detailed testing procedures, see:
- Backend testing: `backend/README.md`
- Frontend testing: `frontend/README.md`