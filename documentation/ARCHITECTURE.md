# Architecture Documentation

YouLend Loan Management Platform - Detailed Architecture

## Table of Contents

1. [System Overview](#system-overview)
2. [Architecture Diagrams](#architecture-diagrams)
3. [Component Details](#component-details)
4. [Data Flow](#data-flow)
5. [Security Architecture](#security-architecture)
6. [Scalability & High Availability](#scalability--high-availability)
7. [Design Decisions](#design-decisions)
8. [Trade-offs](#trade-offs)

---

## System Overview

The YouLend Loan Management Platform is a cloud-native, microservices-based application deployed on AWS EKS (Elastic Kubernetes Service). The system follows a 3-tier architecture with clear separation of concerns.

### Key Characteristics

- **Cloud-Native**: Kubernetes-based, containerized, infrastructure as code
- **Scalable**: Auto-scaling from 3 to 10 replicas based on load
- **Highly Available**: Multi-AZ deployment, 99.9% uptime SLA
- **Secure**: OIDC auth, network policies, container scanning
- **Observable**: Prometheus metrics, Grafana dashboards, Loki logs
- **Automated**: Complete CI/CD with GitHub Actions

---

## Architecture Diagrams

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet Users                           │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            │ DNS Query (youlend.certifiles.com)
                            │
                            ▼
                     ┌─────────────────┐
                     │    Route 53     │
                     │  DNS Resolution │
                     └─────────┬───────┘
                               │
                               │ HTTPS (443)
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Cloud                                │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    VPC (10.0.0.0/16)                      │  │
│  │                                                           │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │              Application Load Balancer              │ │  │
│  │  │                    (Public Subnets)                 │ │  │
│  │  └──────────────┬──────────────────────────┬───────────┘ │  │
│  │                 │                          │             │  │
│  │                 │                          │             │  │
│  │  ┌──────────────▼────────────┐  ┌──────────▼──────────┐ │  │
│  │  │     Frontend Pods         │  │    Backend Pods     │ │  │
│  │  │   (Angular + Nginx)       │  │   (.NET 8 API)      │ │  │
│  │  │   Replicas: 3-10          │  │   Replicas: 3-10    │ │  │
│  │  │   (Private Subnets)       │  │   (Private Subnets) │ │  │
│  │  └───────────────────────────┘  └─────────┬───────────┘ │  │
│  │                                            │             │  │
│  │                                            │             │  │
│  │                                  ┌─────────▼───────────┐ │  │
│  │                                  │  Monitoring Stack   │ │  │
│  │                                  │  - Prometheus       │ │  │
│  │                                  │  - Grafana          │ │  │
│  │                                  │  - Loki             │ │  │
│  │                                  └─────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    Supporting Services                     │  │
│  │  - ECR (Container Registry)                               │  │
│  │  - S3 (Terraform State)                                   │  │
│  │  - DynamoDB (State Locking)                               │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                            │
                            │ OIDC/SAML
                            │
                            ▼
                   ┌─────────────────┐
                   │     Auth0       │
                   │  (External SaaS) │
                   └─────────────────┘
```

### Network Architecture

```
VPC: 10.0.0.0/16
│
├── Public Subnets (3 AZs)
│   ├── 10.0.1.0/24 (us-east-1a) - ALB, NAT Gateway
│   ├── 10.0.2.0/24 (us-east-1b) - ALB, NAT Gateway
│   └── 10.0.3.0/24 (us-east-1c) - ALB, NAT Gateway
│
└── Private Subnets (3 AZs)
    ├── 10.0.10.0/24 (us-east-1a) - EKS Nodes
    ├── 10.0.11.0/24 (us-east-1b) - EKS Nodes
    └── 10.0.12.0/24 (us-east-1c) - EKS Nodes
```

### Kubernetes Architecture

```
EKS Cluster (youlend-eks)
│
├── Namespace: youlend
│   ├── Deployments
│   │   ├── backend (3-10 replicas)
│   │   └── frontend (3-10 replicas)
│   ├── Services
│   │   ├── backend (ClusterIP)
│   │   └── frontend (ClusterIP)
│   ├── HPA
│   │   ├── backend-hpa (CPU: 70%, Memory: 80%)
│   │   └── frontend-hpa (CPU: 70%, Memory: 80%)
│   ├── ConfigMaps
│   │   └── backend-config
│   ├── Secrets
│   │   └── auth0-credentials
│   ├── Ingress
│   │   └── youlend-ingress (ALB)
│   └── NetworkPolicies
│       ├── backend-network-policy
│       ├── frontend-network-policy
│       └── deny-all-default
│
└── Namespace: monitoring
    ├── Prometheus
    ├── Grafana
    ├── Loki
    └── Promtail
```

---

## Component Details

### Frontend (Angular 17)

**Technology:**
- Angular 17 (standalone components)
- Angular Material for UI
- Auth0 for authentication
- RxJS for reactive programming
- TypeScript 5.3

**Deployment:**
- Container: nginx:alpine
- Port: 80
- Health Check: /health
- Resources: 100m-200m CPU, 128Mi-256Mi RAM

**Features:**
- Server-side rendering ready
- AOT compilation
- Tree-shaking for minimal bundle size
- Lazy loading for routes
- Progressive Web App (PWA) ready

### Backend (.NET 8)

**Technology:**
- .NET 8 (latest LTS)
- ASP.NET Core Web API
- FluentValidation for input validation
- Serilog for structured logging
- prometheus-net for metrics

**Deployment:**
- Container: mcr.microsoft.com/dotnet/aspnet:8.0-alpine
- Port: 8080
- Health Checks: /health/live, /health/ready
- Resources: 250m-500m CPU, 256Mi-512Mi RAM

**Architecture Patterns:**
- Repository pattern for data access
- Service layer for business logic
- Dependency injection
- Global exception handling
- Request correlation IDs

**Data Storage:**
- In-memory with ConcurrentDictionary (thread-safe)
- Future: PostgreSQL/SQL Server for persistence

### Infrastructure

**VPC:**
- CIDR: 10.0.0.0/16
- 3 Availability Zones for HA
- Public subnets for ALB, NAT Gateways
- Private subnets for EKS nodes
- VPC Flow Logs enabled

**EKS:**
- Kubernetes version: 1.28
- Managed node groups (t3.medium)
- OIDC provider for IRSA
- EKS add-ons: VPC CNI, CoreDNS, kube-proxy
- Cluster auto-scaler enabled

**ECR:**
- Private container registry
- Image scanning enabled
- Lifecycle policies (keep last 10)
- Encryption at rest (AES256)

---

## Data Flow

### User Request Flow

```
1. User accesses https://youlend.certifiles.com
   │
   ▼
2. Route 53 resolves DNS to ALB endpoint
   │
   ▼
3. ALB terminates HTTPS, routes to Frontend pods
   │
   ▼
4. Frontend serves Angular SPA
   │
   ▼
5. User authenticates via Auth0 (OIDC)
   │
   ▼
6. Frontend calls Backend API with JWT token
   │
   ▼
7. Backend validates JWT, processes request
   │
   ▼
8. Backend returns JSON response
   │
   ▼
9. Frontend updates UI
```

### CI/CD Flow

```
1. Developer pushes code to GitHub
   │
   ▼
2. GitHub Actions triggers (Backend CI, Frontend CI, Security Scan)
   │
   ▼
3. Tests run (55 backend tests, frontend unit tests)
   │
   ▼
4. Security scans (Trivy, CodeQL, Gitleaks)
   │
   ▼
5. PR approved and merged to main
   │
   ▼
6. Docker images built and pushed to ECR
   │
   ▼
7. Helm deployment to Development (automatic)
   │
   ▼
8. Smoke tests run
   │
   ▼
9. Manual approval for Production
   │
   ▼
10. Helm deployment to Production
    │
    ▼
11. Production smoke tests
```

### Observability Flow

```
Backend Pods → Prometheus (metrics) → Grafana (visualization)
             ↘ Serilog (logs) → Loki → Grafana (logs)
             
Frontend Pods → Nginx logs → Promtail → Loki → Grafana
```

---

## Security Architecture

### Network Security

**Network Policies:**
- Default deny all traffic
- Frontend can only communicate with Backend
- Backend can communicate with external Auth0
- All pods can access DNS

**Security Groups:**
- ALB security group: Allow 80/443 from internet
- Cluster security group: Allow 443 from workstations
- Node security group: Managed by EKS

### Application Security

**Authentication:**
- Auth0 for user authentication (OIDC)
- JWT tokens for API authorization
- Token validation on every request

**Container Security:**
- Non-root users (backend: 1000, frontend: 101)
- Read-only root filesystem (frontend)
- All Linux capabilities dropped
- Seccomp profiles enforced

**API Security:**
- Input validation (FluentValidation)
- CORS configured for allowed origins
- Rate limiting
- Security headers (HSTS, CSP, X-Frame-Options)

### Infrastructure Security

**IAM:**
- OIDC authentication (no long-lived keys)
- Least privilege access
- Separate roles for cluster, nodes, services

**Encryption:**
- HTTPS/TLS for all traffic
- ECR images encrypted at rest
- Terraform state encrypted (S3 + AES256)
- EKS secrets encrypted with AWS KMS

**Scanning:**
- Trivy container scanning (daily)
- CodeQL static analysis
- Gitleaks secret detection
- Dependency vulnerability scanning

---

## Scalability & High Availability

### Horizontal Scaling

**Auto-Scaling:**
- HPA for backend: 3-10 replicas based on CPU (70%) and Memory (80%)
- HPA for frontend: 3-10 replicas based on CPU (70%) and Memory (80%)
- Cluster auto-scaler for nodes (3-10 nodes)

**Scaling Behavior:**
- Scale up: Fast (100% in 15s or 2 pods per 60s)
- Scale down: Gradual (50% per 60s, 5min stabilization)

### High Availability

**Multi-AZ Deployment:**
- Resources spread across 3 availability zones
- Pod anti-affinity rules (prefer different nodes)
- PodDisruptionBudgets (minAvailable: 2)

**Rolling Updates:**
- Zero-downtime deployments
- MaxSurge: 1, MaxUnavailable: 0
- Health checks before marking ready

**Health Checks:**
- Liveness probes: Restart unhealthy pods
- Readiness probes: Remove from load balancer if not ready
- Startup probes: Allow longer initialization

### Load Balancing

**ALB (Application Load Balancer):**
- Cross-zone load balancing enabled
- Connection draining (30s)
- Health checks every 15s
- Sticky sessions enabled

**Kubernetes Services:**
- ClusterIP services for internal communication
- Session affinity: None (stateless apps)

---

## Design Decisions

### Why .NET 8?

**Pros:**
- Latest LTS version with long-term support
- Excellent performance (faster than .NET 6)
- Native AOT compilation support
- Minimal Docker images with Alpine
- Built-in dependency injection
- Strong typing and compile-time safety

**Cons:**
- Larger memory footprint than Node.js
- Longer startup time than interpreted languages

**Decision:** Performance and type safety outweigh startup time for a business-critical API.

### Why Angular 17?

**Pros:**
- Standalone components (no NgModules)
- Built-in RxJS for reactive programming
- Strong TypeScript integration
- Mature ecosystem (Material, Auth0)
- AOT compilation for fast runtime

**Cons:**
- Steeper learning curve than React
- Larger bundle size than Vue

**Decision:** Enterprise-grade framework with comprehensive tooling and type safety.

### Why EKS over ECS?

**Pros:**
- Vendor-neutral (can migrate to other clouds)
- Rich ecosystem (Helm, operators)
- Better for multi-cloud strategy
- Industry standard for container orchestration

**Cons:**
- More complex than ECS
- Higher learning curve
- More expensive (EC2 + EKS control plane)

**Decision:** Kubernetes skills are transferable and future-proof.

### Why Helm over Raw Manifests?

**Pros:**
- Parameterized deployments (dev/prod)
- Version management and rollbacks
- Reusable charts
- Templating reduces duplication

**Cons:**
- Additional abstraction layer
- Learning curve for templating

**Decision:** Benefits of parameterization outweigh complexity.

### Why OIDC over AWS Access Keys?

**Pros:**
- No long-lived credentials
- Automatic rotation
- Audit trail via CloudTrail
- Better security posture

**Cons:**
- More complex initial setup
- Requires trust relationship configuration

**Decision:** Security best practice, eliminates key management burden.

---

## Trade-offs

### In-Memory Storage vs Database

**Current:** ConcurrentDictionary (in-memory)
**Trade-off:** Simplicity vs Persistence

**Pros:**
- Fast (no network latency)
- Simple (no DB setup required)
- Sufficient for demo/MVP

**Cons:**
- Data lost on restart
- No data durability
- Limited to single instance (not truly scalable)

**Future:** Migrate to PostgreSQL/SQL Server for production.

### Single NAT Gateway vs Multi-AZ NAT

**Current:** 3 NAT Gateways (one per AZ)
**Trade-off:** Cost vs High Availability

**Pros of 3 NAT Gateways:**
- True high availability
- No single point of failure
- Better performance (local to AZ)

**Cons of 3 NAT Gateways:**
- ~$100/month vs ~$33/month (single NAT)
- Higher data transfer costs

**Decision:** Chose HA for production; can switch to single NAT for dev to save costs.

### EKS Managed Nodes vs Fargate

**Current:** Managed node groups
**Trade-off:** Control vs Serverless

**Pros of Managed Nodes:**
- Full control over instance types
- Ability to use DaemonSets
- Lower cost at scale
- Better performance

**Cons of Managed Nodes:**
- Manual capacity planning
- Need to manage node upgrades
- Not truly serverless

**Decision:** Managed nodes give more control and lower costs for our scale.

### Prometheus vs CloudWatch

**Current:** Prometheus + Grafana
**Trade-off:** Control vs Managed Service

**Pros of Prometheus:**
- Open-source, vendor-neutral
- Rich query language (PromQL)
- Community dashboards
- No per-metric costs

**Cons of Prometheus:**
- Need to manage ourselves
- Storage and retention concerns
- Additional infrastructure

**Decision:** Prometheus gives better metrics and community support; worth the operational overhead.

---

## Future Enhancements

### Short-term (Next 3 months)

1. **Persistent Storage**: Migrate to PostgreSQL
2. **Caching**: Add Redis for session/data caching
3. **Rate Limiting**: Implement API rate limiting
4. **Advanced Monitoring**: Add distributed tracing (Tempo/Jaeger)

### Medium-term (6-12 months)

1. **Multi-Region**: Deploy to multiple AWS regions
2. **CDN**: CloudFront for frontend static assets
3. **Advanced Auth**: MFA, SSO, fine-grained permissions
4. **API Gateway**: Kong or AWS API Gateway

### Long-term (1+ years)

1. **Event-Driven**: Event sourcing with Kafka/EventBridge
2. **Microservices**: Split backend into multiple services
3. **Service Mesh**: Istio for advanced traffic management
4. **Multi-Cloud**: Deploy to Azure/GCP for redundancy

---

## Conclusion

The YouLend Loan Management Platform is built with production-grade architecture, following cloud-native best practices. The system is secure, scalable, highly available, and fully automated with comprehensive CI/CD and observability.

Key architectural strengths:
- ✅ Modern tech stack (.NET 8, Angular 17, Kubernetes)
- ✅ Cloud-native patterns (containers, IaC, auto-scaling)
- ✅ Security-first approach (OIDC, scanning, network policies)
- ✅ Complete automation (CI/CD, IaC, monitoring)
- ✅ Production-ready (HA, monitoring, rollbacks)

The architecture is designed to evolve with business needs while maintaining operational excellence.
