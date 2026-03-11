# Helm Charts

Production-ready Helm charts for the YouLend Loan Management Platform.

## Charts Available

### youlend (v1.0.0)

Complete Helm chart for deploying the full YouLend application stack on Kubernetes.

**Components:**
- Backend API (.NET 8)
- Frontend SPA (Angular 17)
- AWS ALB Ingress
- Network Policies
- Horizontal Pod Autoscalers
- PodDisruptionBudgets

See [youlend/README.md](youlend/README.md) for detailed documentation.

## Quick Start

```bash
# Install chart
cd infrastructure/helm
helm install youlend ./youlend

# Install with dev configuration
helm install youlend ./youlend -f youlend/values-dev.yaml

# Install with production configuration
helm install youlend ./youlend -f youlend/values-prod.yaml
```

## Chart Structure

```
youlend/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default values (production)
├── values-dev.yaml         # Development overrides
├── values-prod.yaml        # Production overrides
├── templates/
│   ├── _helpers.tpl        # Template helpers
│   ├── NOTES.txt           # Post-install notes
│   ├── namespace.yaml      # Namespace
│   ├── backend-*.yaml      # Backend resources
│   ├── frontend-*.yaml     # Frontend resources
│   ├── ingress.yaml        # ALB Ingress
│   ├── network-policy.yaml # Network policies
│   └── secrets.yaml        # Secrets
└── README.md               # Chart documentation
```

## Environment Configurations

### Development
- Lower resource limits
- Single replica (no HPA)
- HTTP only
- Debug logging

```bash
helm install youlend ./youlend -f youlend/values-dev.yaml
```

### Production
- Higher resource limits
- 5-20 replicas with HPA
- HTTPS with ACM certificate
- Info logging
- Deletion protection

```bash
helm install youlend ./youlend -f youlend/values-prod.yaml \
  --set secrets.auth0.domain=your-domain.auth0.com \
  --set ingress.certificateArn=arn:aws:acm:...
```

## Validation

```bash
# Lint chart
helm lint ./youlend

# Dry run
helm install youlend ./youlend --dry-run --debug

# Template rendering
helm template youlend ./youlend
```

## Package & Distribution

```bash
# Package chart
helm package ./youlend

# Creates: youlend-1.0.0.tgz

# Install from package
helm install youlend ./youlend-1.0.0.tgz
```

## Common Operations

### Upgrade

```bash
# Upgrade with new image
helm upgrade youlend ./youlend --set backend.image.tag=v1.1.0

# Upgrade with new values
helm upgrade youlend ./youlend -f youlend/values-prod.yaml
```

### Rollback

```bash
# Rollback to previous version
helm rollback youlend

# View history
helm history youlend
```

### Uninstall

```bash
# Uninstall chart
helm uninstall youlend -n youlend
```

## Chart Development

When modifying the chart:

1. Update version in `Chart.yaml`
2. Test with `helm lint ./youlend`
3. Validate with `helm install --dry-run`
4. Document changes in chart README
5. Package with `helm package ./youlend`

## Prerequisites

- Kubernetes 1.28+
- Helm 3.0+
- AWS Load Balancer Controller
- Metrics Server (for HPA)
- ECR access configured

## Support

For chart-related issues:
- See chart README: [youlend/README.md](youlend/README.md)
- GitHub Issues: https://github.com/Hafizyishawu/youlend-loan-platform/issues

## Next Steps

After Helm deployment:
1. Configure Auth0 credentials
2. Set up ACM certificate for HTTPS
3. Configure DNS for custom domain
4. Set up monitoring (Prometheus/Grafana)
5. Configure CI/CD for automated deployments
