# Security Documentation

Security architecture, practices, and compliance for YouLend Loan Management Platform.

## Security Overview

The platform implements defense-in-depth with multiple security layers:

- **Application Security**: Input validation, authentication, authorization
- **Container Security**: Non-root users, read-only filesystems, minimal images
- **Network Security**: Network policies, private subnets, security groups
- **Infrastructure Security**: OIDC auth, encryption, least privilege IAM
- **CI/CD Security**: Secret scanning, vulnerability scanning, SAST
- **Monitoring**: Security events, audit logs, alerting

## Authentication & Authorization

### User Authentication

**Auth0 (OIDC/OAuth 2.0):**
- Industry-standard authentication
- Multi-factor authentication (MFA) supported
- Social login supported
- Session management
- Token refresh

**JWT Tokens:**
- Short-lived access tokens (1 hour)
- Refresh tokens for extended sessions
- Token validation on every API request
- Claims-based authorization

### Service Authentication

**OIDC for GitHub Actions:**
- No long-lived AWS credentials
- Temporary credentials (1 hour)
- Automatic rotation
- Audit trail via CloudTrail

**IRSA (IAM Roles for Service Accounts):**
- Kubernetes pods assume IAM roles
- No AWS keys in containers
- Fine-grained permissions

## Application Security

### Input Validation

**FluentValidation:**
- All API inputs validated
- Business rules enforced
- XSS prevention
- SQL injection prevention (not applicable with in-memory storage)

**Validation Rules:**
```csharp
- LoanID: Required, positive integer
- BorrowerName: Required, max 100 chars, alphanumeric
- FundingAmount: Required, > 0
- RepaymentAmount: Required, > FundingAmount
```

### API Security

**CORS Configuration:**
```csharp
AllowedOrigins: https://youlend.example.com
AllowedMethods: GET, POST, DELETE
AllowCredentials: true
```

**Security Headers:**
- `X-Frame-Options: DENY` (clickjacking protection)
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection: 1; mode=block`
- `Strict-Transport-Security: max-age=31536000`
- `Content-Security-Policy: default-src 'self'`

**Rate Limiting:**
- 100 requests per minute per IP
- Prevents brute force attacks
- DDoS mitigation

## Container Security

### Image Hardening

**Base Images:**
- Backend: `mcr.microsoft.com/dotnet/aspnet:8.0-alpine`
- Frontend: `nginx:alpine`
- Minimal attack surface (Alpine Linux)

**Non-Root Users:**
- Backend runs as user `appuser` (UID: 1000)
- Frontend runs as user `nginx` (UID: 101)
- Prevents privilege escalation

**Filesystem:**
- Frontend: Read-only root filesystem
- Backend: Writable temp directories only
- Prevents malware persistence

**Capabilities:**
- All Linux capabilities dropped
- Minimal permissions (NET_BIND_SERVICE only if needed)

### Vulnerability Scanning

**Trivy (Daily Scans):**
- Scans all images for CVEs
- Fails on CRITICAL/HIGH vulnerabilities
- Results uploaded to GitHub Security

**Scan Results:**
```bash
# View scan results
gh api repos/Hafizyishawu/youlend-loan-platform/code-scanning/alerts
```

## Network Security

### Network Policies

**Default Deny:**
```yaml
All traffic denied by default
Explicit allow rules:
  - Frontend → Backend (port 8080)
  - Pods → DNS (port 53)
  - Backend → Auth0 (port 443)
```

**Isolation:**
- Frontend cannot access monitoring namespace
- Backend cannot access frontend directly
- No pod-to-pod communication except explicitly allowed

### Network Architecture

**Public Subnets:**
- ALB only
- NAT Gateways
- No EC2 instances

**Private Subnets:**
- EKS nodes only
- No direct internet access
- Egress via NAT Gateway

**Security Groups:**
- ALB: Allow 80/443 from 0.0.0.0/0
- Cluster: Allow 443 from authorized IPs
- Nodes: Managed by EKS (minimal exposure)

## Infrastructure Security

### IAM Least Privilege

**GitHub Actions Role:**
```json
Permissions:
  - ECR: Push/Pull images
  - EKS: UpdateKubeconfig
  - S3: Terraform state (specific bucket)
  - DynamoDB: State locking (specific table)

Deny:
  - EC2 instance management
  - IAM user/role creation
  - Billing access
```

**EKS Node Role:**
```json
Permissions:
  - ECR: Pull images
  - EKS: Join cluster
  - CloudWatch: Write logs

Deny:
  - S3 access
  - IAM changes
  - Other AWS services
```

### Encryption

**Data in Transit:**
- HTTPS/TLS 1.2+ for all external traffic
- TLS between ALB and pods
- mTLS between services (future: service mesh)

**Data at Rest:**
- ECR images: AES256
- Terraform state (S3): AES256
- EKS secrets: AWS KMS
- Monitoring data: Encrypted volumes

**Encryption Keys:**
- AWS managed keys (KMS)
- Automatic rotation
- Audit trail via CloudTrail

### Secrets Management

**GitHub Secrets:**
- Encrypted at rest
- Only accessible to workflows
- Audit log of access

**Kubernetes Secrets:**
- Base64 encoded (not encrypted by default)
- Encrypted at rest with KMS
- RBAC controls access
- Rotated regularly

**Best Practices:**
- No secrets in code
- No secrets in Docker images
- No secrets in environment variables (use volume mounts)
- Rotate secrets every 90 days

## CI/CD Security

### Source Code Security

**Gitleaks (Secret Scanning):**
- Scans every commit for secrets
- Prevents AWS keys, passwords, tokens in code
- Pre-commit hooks available

**CodeQL (SAST):**
- Static analysis for C# and JavaScript
- Detects security vulnerabilities
- SQL injection, XSS, insecure crypto

### Dependency Scanning

**.NET Dependencies:**
```bash
dotnet list package --vulnerable
```

**npm Dependencies:**
```bash
npm audit
npm audit fix
```

**Automated:**
- Dependabot enabled
- Weekly scans
- Automatic PRs for updates

### Build Security

**Docker Build:**
- Multi-stage builds (no build tools in runtime image)
- Scan before push
- Sign images (future: Sigstore/Cosign)

**GitHub Actions:**
- OIDC authentication (no keys)
- Least privilege permissions
- Approved actions only
- Branch protection rules

## Compliance & Auditing

### Logging

**Application Logs:**
- Structured logging (Serilog)
- Centralized in Loki
- Retention: 7 days
- Searchable via Grafana

**Audit Logs:**
- Kubernetes audit logs enabled
- AWS CloudTrail enabled
- GitHub audit log enabled
- Retained for 90 days

**Log Contents:**
- Request IDs (correlation)
- User actions
- Authentication events
- Authorization failures
- Security events

### Monitoring & Alerting

**Security Alerts:**
- Failed authentication attempts
- Authorization failures
- Pod security context violations
- Network policy violations
- Vulnerability scan failures

**Alert Destinations:**
- Slack channel: #security-alerts
- Email: abdulyishawu333@gmail.com
- PagerDuty for critical (future)

### Compliance

**GDPR Considerations:**
- User data minimization
- Right to deletion (DELETE /loans/{id})
- Data retention policies
- Audit logging

**SOC 2 Readiness:**
- Access controls (RBAC)
- Encryption (in-transit, at-rest)
- Logging and monitoring
- Incident response plan

## Incident Response

### Security Incident Procedure

1. **Detection**: Alert triggered or manually reported
2. **Containment**: Isolate affected resources
3. **Investigation**: Review logs, identify root cause
4. **Remediation**: Patch vulnerability, rotate secrets
5. **Recovery**: Restore services
6. **Post-Mortem**: Document lessons learned

### Runbook

**Compromised Container:**
```bash
# 1. Identify pod
kubectl get pods -n youlend

# 2. Delete pod
kubectl delete pod <pod-name> -n youlend

# 3. Check for persistence
kubectl get all -n youlend

# 4. Review logs
kubectl logs <pod-name> -n youlend --previous

# 5. Scan image
trivy image <image>:tag
```

**Compromised AWS Credentials:**
```bash
# 1. Rotate credentials immediately
aws iam update-access-key --access-key-id XXX --status Inactive

# 2. Review CloudTrail
aws cloudtrail lookup-events --lookup-attributes ...

# 3. Check for unauthorized resources
aws ec2 describe-instances
aws s3 ls

# 4. Rotate all secrets
# See secrets rotation playbook
```

## Security Best Practices

### For Developers

- [ ] Never commit secrets to code
- [ ] Use FluentValidation for all inputs
- [ ] Always use HTTPS
- [ ] Implement proper error handling
- [ ] Log security events
- [ ] Keep dependencies updated
- [ ] Run security scans locally
- [ ] Follow principle of least privilege

### For Operations

- [ ] Enable MFA for all AWS accounts
- [ ] Use OIDC instead of access keys
- [ ] Rotate secrets every 90 days
- [ ] Review IAM permissions quarterly
- [ ] Monitor security alerts
- [ ] Patch vulnerabilities within SLA
- [ ] Conduct regular security audits
- [ ] Maintain incident response playbook

### For Users

- [ ] Enable MFA in Auth0
- [ ] Use strong passwords
- [ ] Don't share credentials
- [ ] Log out when finished
- [ ] Report suspicious activity

## Security Contact

**Report Security Issues:**
- Email: abdulyishawu333@gmail.com
- PGP Key: Available on request
- Response SLA: 24 hours

**Do NOT:**
- Open public GitHub issues for security vulnerabilities
- Disclose vulnerabilities publicly before patch

## Security Certifications

- ISO 27001 (in progress)
- SOC 2 Type II (planned)
- PCI DSS (if handling payments)

## Regular Security Activities

### Daily
- Automated vulnerability scans (Trivy)
- Dependency scans
- Secret scanning

### Weekly
- Review security alerts
- Review failed auth attempts
- Update dependencies

### Monthly
- Security patch deployment
- Access review
- Incident response drill

### Quarterly
- IAM permission review
- Security training
- Penetration testing
- Compliance audit

## Conclusion

Security is a shared responsibility. This document outlines our security posture, but security is everyone's job. Stay vigilant, follow best practices, and report any concerns immediately.

**Last Updated**: 2024-03-07
**Next Review**: 2024-06-07
