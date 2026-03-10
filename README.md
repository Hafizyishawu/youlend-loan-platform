# YouLend Loan Management Platform

Production-ready loan management platform built with .NET 8, Angular 17, and deployed on AWS EKS.

Live at https://youlend.certifiles.com

## Overview

A comprehensive loan management system with a .NET backend API, Angular frontend, and complete cloud-native infrastructure on AWS.

### Key Features

- ✅ **Backend API**: .NET 8 REST API with 55 passing tests
- ✅ **Frontend SPA**: Angular 17 with Material Design
- ✅ **Infrastructure**: Complete AWS infrastructure (VPC, EKS, ECR)
- ✅ **Kubernetes**: Production-ready manifests with auto-scaling
- ✅ **Helm Charts**: Parameterized deployments
- ✅ **CI/CD**: GitHub Actions with OIDC authentication
- ✅ **Security**: Trivy scanning, SAST, secret detection
- ✅ **Observability**: Prometheus, Grafana, Loki
- ✅ **Documentation**: Comprehensive guides and architecture docs

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Internet                             │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
                  ┌──────────────┐
                  │  Route 53    │
                  │     DNS      │
                  └──────┬───────┘
                         │
                         ▼
                  ┌──────────────┐
                  │   AWS ALB    │
                  │   (HTTPS)    │
                  └──────┬───────┘
                         │
            ┌────────────┴────────────┐
            │                         │
            ▼                         ▼
    ┌───────────────┐         ┌──────────────┐
    │   Frontend    │         │   Backend    │
    │   Angular 17  │────────▶│   .NET 8     │
    │   (Nginx)     │         │   REST API   │
    └───────────────┘         └──────┬───────┘
                                     │
                              ┌──────┴────────┐
                              │               │
                              ▼               ▼
                         ┌────────┐     ┌─────────┐
                         │ Auth0  │     │  Logs   │
                         └────────┘     │ Metrics │
                                       └─────────┘
```

**Infrastructure:**
- Route 53 for DNS management (youlend.certifiles.com)
- VPC with 3 AZs, public + private subnets
- EKS cluster (v1.28) with managed node groups
- ECR for container images
- ALB for internet exposure with SSL/TLS termination
- Prometheus + Grafana + Loki for observability

See [ARCHITECTURE.md](documentation/ARCHITECTURE.md) for detailed architecture.


## Business Rules

### Loan Validation
- **Borrower Name**: Required, max 100 characters
- **Funding Amount**: Required, must be between £0.01 and £1,000,000,000
- **Repayment Amount**: Required, must be between £0.01 and £1,000,000,000
- **Business Rule**: Repayment amount must be ≥ Funding amount (enforced on both frontend and backend)

### Form Behavior
- Submit button is disabled until all validation rules are met
- Real-time validation provides immediate feedback
- Error messages guide users to correct input

## Quick Start

### Prerequisites

- Docker
- kubectl
- Helm 3.x
- AWS CLI (configured with profile `youlend`)
- Node.js 20+ (for frontend)
- .NET 8 SDK (for backend)

### Local Development

**Backend:**
```bash
cd backend
dotnet restore
dotnet run

# Run tests
dotnet test
```

API available at: http://localhost:8080

**Frontend:**
```bash
cd frontend
npm install
npm start
```

App available at: http://localhost:4200

### Deploy to AWS

See [DEPLOYMENT.md](documentation/DEPLOYMENT.md) for complete deployment guide.

**Quick deployment:**
```bash
# 1. Setup Terraform backend
cd infrastructure/terraform
./setup-backend.sh

# 2. Deploy infrastructure
./init.sh
./apply.sh

# 3. Configure kubectl
$(terraform output -raw configure_kubectl)

# 4. Deploy application
cd ../helm
helm install youlend ./youlend
```

## Project Structure

```
youlend-loan-platform/
├── backend/                    # .NET 8 Backend API
│   ├── src/LoanApi/           # API implementation
│   ├── tests/                 # Unit & integration tests (55 tests)
│   └── Dockerfile             # Multi-stage Docker build
├── frontend/                   # Angular 17 Frontend
│   ├── src/                   # Application source
│   ├── tests/                 # Unit tests
│   └── Dockerfile             # Multi-stage Docker build
├── infrastructure/
│   ├── terraform/             # Infrastructure as Code
│   │   ├── modules/           # Reusable modules (VPC, EKS, ECR)
│   │   └── *.tf               # Root configuration
│   ├── k8s/                   # Kubernetes manifests
│   │   ├── backend/           # Backend resources
│   │   ├── frontend/          # Frontend resources
│   │   └── *.yaml             # Shared resources
│   ├── helm/                  # Helm charts
│   │   └── youlend/           # Main chart
│   ├── docker/                # Docker utilities
│   └── monitoring/            # Observability stack
├── .github/workflows/          # CI/CD pipelines
└── docs/                      # Additional documentation
```

## Technology Stack

### Backend
- **Framework**: .NET 8, ASP.NET Core
- **Validation**: FluentValidation
- **Logging**: Serilog
- **Metrics**: prometheus-net
- **Testing**: xUnit, Moq, FluentAssertions
- **API Docs**: Swagger/OpenAPI

### Frontend
- **Framework**: Angular 17 (standalone)
- **UI**: Angular Material
- **Auth**: Auth0
- **HTTP**: RxJS
- **Testing**: Jasmine, Karma

### Infrastructure
- **Cloud**: AWS (VPC, EKS, ECR, ALB)
- **IaC**: Terraform 1.6+
- **Orchestration**: Kubernetes 1.28
- **Package Manager**: Helm 3
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus, Grafana, Loki

## Features

### API Endpoints

- `POST /api/v1/loans` - Create loan
- `GET /api/v1/loans` - List all loans
- `GET /api/v1/loans/{id}` - Get loan by ID
- `GET /api/v1/loans/borrower/{name}` - Get loans by borrower
- `DELETE /api/v1/loans/{id}` - Delete loan

### Frontend Features

- Loan creation form with validation
- Loan list with search and filter
- Loan details view
- Loan editing
- Material Design UI
- Auth0 authentication
- Responsive design

### DevOps Features

- **Auto-scaling**: HPA (3-10 replicas)
- **High Availability**: 3 AZs, PodDisruptionBudgets
- **Security**: Non-root containers, read-only filesystems, network policies
- **Monitoring**: Metrics, logs, dashboards
- **CI/CD**: Automated testing, building, and deployment
- **Security Scanning**: Trivy, CodeQL, Gitleaks

## Testing

### Backend Tests

```bash
cd backend
dotnet test --verbosity normal

# With coverage
dotnet test --collect:"XPlat Code Coverage"
```

**Test Coverage**: 55 tests (repository, service, validator, integration)

### Frontend Tests

```bash
cd frontend
npm test

# With coverage
npm test -- --code-coverage
```

## Security

See [SECURITY.md](documentation/SECURITY.md) for security documentation.

**Key Security Features:**
- OIDC authentication (no AWS keys)
- Container image scanning (Trivy)
- Static analysis (CodeQL)
- Secret detection (Gitleaks)
- Network policies
- Non-root containers
- Read-only filesystems where possible

## Monitoring

Access Grafana dashboards:

```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Default credentials: `admin` / `CHANGE_ME_SECURE_PASSWORD`

**Available Dashboards:**
- Backend API metrics
- Kubernetes cluster overview
- Node exporter metrics

See [MONITORING.md](documentation/infrastructure/MONITORING.md)

## CI/CD

GitHub Actions workflows:

- **On Pull Request**: Backend CI, Frontend CI, Security Scan, Terraform Plan
- **On Merge to Main**: Build Docker images, Deploy to Dev, Terraform Apply
- **Manual**: Deploy to Production (requires approval)

See GitHub Actions workflows in [.github/workflows/](.github/workflows/)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is proprietary software owned by YouLend.

## Documentation

- [Architecture Documentation](documentation/ARCHITECTURE.md)
- [Deployment Guide](documentation/DEPLOYMENT.md)
- [Security Documentation](documentation/SECURITY.md)
- [Testing Guide](documentation/TESTING.md)
- [Infrastructure Documentation](documentation/infrastructure/)
- [API Documentation](http://localhost:8080/swagger) (when running)

## Support

For issues and questions:
- **Email**: abdulyishawu333@gmail.com
- **GitHub Issues**: https://github.com/Hafizyishawu/youlend-loan-platform/issues

## Author

**Abdul Hafiz Yishawu**
- DevSecOps/Platform Engineer
- MSc Cybersecurity (Distinction), University of Chester
- ISC2 CC Certified
- GitHub: [@Hafizyishawu](https://github.com/Hafizyishawu)
