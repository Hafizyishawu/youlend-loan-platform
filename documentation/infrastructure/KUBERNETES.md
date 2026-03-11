# Kubernetes Deployment

Production-ready Kubernetes manifests for YouLend Loan Management Platform.

## Architecture

```
                    Internet
                        │
                        ▼
                  ALB (Ingress)
                   HTTPS/443
                        │
           ┌────────────┴────────────┐
           │                         │
           ▼                         ▼
      Frontend (3-10 pods)    Backend API (3-10 pods)
      Nginx + Angular         .NET 8 API
      Port 80                 Port 8080
           │                         │
           └─────────►Auth0◄─────────┘
```

## Components

### Namespace
- **youlend** - Isolated namespace for all application resources

### Backend
- **Deployment:** 3 replicas (min), 10 (max with HPA)
- **Service:** ClusterIP on port 80 → 8080
- **HPA:** CPU 70%, Memory 80%
- **PDB:** minAvailable: 2
- **Resources:** 250m-500m CPU, 256Mi-512Mi memory
- **Probes:** /health/live (liveness), /health/ready (readiness)

### Frontend
- **Deployment:** 3 replicas (min), 10 (max with HPA)
- **Service:** ClusterIP on port 80
- **HPA:** CPU 70%, Memory 80%
- **PDB:** minAvailable: 2
- **Resources:** 100m-200m CPU, 128Mi-256Mi memory
- **Probes:** /health (liveness & readiness)

### Ingress
- **Type:** ALB (AWS Load Balancer Controller)
- **Scheme:** Internet-facing
- **Protocol:** HTTP (80) → HTTPS (443) redirect
- **Routing:**
  - `/api/*` → Backend service
  - `/health` → Backend service
  - `/metrics` → Backend service
  - `/*` → Frontend service

### Network Policies
- **Backend:** Allow ingress from frontend + ingress controller; egress to DNS + external HTTPS
- **Frontend:** Allow ingress from ingress controller; egress to backend + DNS + external HTTPS
- **Default:** Deny all other traffic

## Prerequisites

### 1. EKS Cluster

```bash
# Cluster should be running with:
- Kubernetes version: 1.28+
- Node type: t3.medium or larger
- Min nodes: 3
- Max nodes: 10
```

### 2. AWS Load Balancer Controller

Install the AWS Load Balancer Controller:

```bash
# Add EKS chart repo
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=youlend-eks \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### 3. Metrics Server

Required for HPA:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### 4. ECR Access

Ensure nodes have ECR pull permissions:

```bash
# Verify nodes can pull from ECR
kubectl run test --image=YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/youlend-backend:latest --rm -it
```

## Deployment

### Quick Deploy

```bash
cd infrastructure/k8s
chmod +x deploy.sh
./deploy.sh
```

### Manual Deploy

```bash
# 1. Create namespace
kubectl apply -f namespace.yaml

# 2. Create secrets (update with real values first!)
kubectl apply -f secrets.yaml

# 3. Create ConfigMaps
kubectl apply -f backend/configmap.yaml

# 4. Deploy backend
kubectl apply -f backend/

# 5. Deploy frontend
kubectl apply -f frontend/

# 6. Apply network policies
kubectl apply -f network-policy.yaml

# 7. Create ingress
kubectl apply -f ingress.yaml
```

## Configuration

### Update Secrets

Before deploying, update `secrets.yaml` with your Auth0 credentials:

```bash
# Edit secrets
nano secrets.yaml

# Update these values:
AUTH0_DOMAIN: "your-domain.auth0.com"
AUTH0_CLIENT_ID: "your-client-id"
```

Apply secrets:

```bash
kubectl apply -f secrets.yaml
```

### Update Image Tags

To deploy a specific version:

```bash
# Edit deployments
nano backend/deployment.yaml
nano frontend/deployment.yaml

# Change image tag from :latest to :v1.0.0
# image: YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/youlend-backend:v1.0.0

# Apply changes
kubectl apply -f backend/deployment.yaml
kubectl apply -f frontend/deployment.yaml
```

### Configure ACM Certificate

For HTTPS with custom domain:

```bash
# 1. Request certificate in ACM
aws acm request-certificate \
  --domain-name youlend.example.com \
  --validation-method DNS \
  --region us-east-1

# 2. Get certificate ARN
aws acm list-certificates --region us-east-1

# 3. Update ingress.yaml
nano ingress.yaml

# Uncomment and update:
# alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:ACCOUNT:certificate/CERT_ID

# 4. Apply
kubectl apply -f ingress.yaml
```

## Monitoring

### Check Pod Status

```bash
# All pods
kubectl get pods -n youlend

# Specific app
kubectl get pods -n youlend -l app=backend
kubectl get pods -n youlend -l app=frontend
```

### View Logs

```bash
# Backend logs
kubectl logs -n youlend -l app=backend --tail=100 -f

# Frontend logs
kubectl logs -n youlend -l app=frontend --tail=100 -f

# Specific pod
kubectl logs -n youlend <pod-name> -f
```

### Check HPA Status

```bash
# View autoscalers
kubectl get hpa -n youlend

# Describe HPA
kubectl describe hpa backend -n youlend
kubectl describe hpa frontend -n youlend
```

### Check Ingress

```bash
# Get ingress details
kubectl get ingress -n youlend

# Describe ingress
kubectl describe ingress youlend-ingress -n youlend

# Get ALB DNS
kubectl get ingress youlend-ingress -n youlend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

### Resource Usage

```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods -n youlend
```

## Scaling

### Manual Scaling

```bash
# Scale backend
kubectl scale deployment backend -n youlend --replicas=5

# Scale frontend
kubectl scale deployment frontend -n youlend --replicas=5
```

### Update HPA Thresholds

```bash
# Edit HPA
kubectl edit hpa backend -n youlend

# Modify targetCPUUtilizationPercentage or minReplicas/maxReplicas
```

## Updates & Rollouts

### Rolling Update

```bash
# Update image
kubectl set image deployment/backend backend=YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/youlend-backend:v1.1.0 -n youlend

# Watch rollout
kubectl rollout status deployment/backend -n youlend
```

### Rollback

```bash
# Rollback to previous version
kubectl rollout undo deployment/backend -n youlend

# Rollback to specific revision
kubectl rollout undo deployment/backend -n youlend --to-revision=2

# Check rollout history
kubectl rollout history deployment/backend -n youlend
```

## Troubleshooting

### Pods Not Starting

```bash
# Describe pod
kubectl describe pod <pod-name> -n youlend

# Common issues:
# - Image pull errors: Check ECR permissions
# - CrashLoopBackOff: Check application logs
# - Pending: Check node resources
```

### Health Check Failures

```bash
# Check probe configuration
kubectl describe pod <pod-name> -n youlend

# Test health endpoint manually
kubectl port-forward -n youlend <pod-name> 8080:8080
curl http://localhost:8080/health/live
```

### Ingress Not Working

```bash
# Check ALB creation
kubectl describe ingress youlend-ingress -n youlend

# Verify AWS Load Balancer Controller
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Check target groups in AWS Console
aws elbv2 describe-target-groups --region us-east-1
```

### Network Policy Issues

```bash
# Temporarily disable network policies for debugging
kubectl delete networkpolicy --all -n youlend

# Re-apply after fixing
kubectl apply -f network-policy.yaml
```

## Security

### Security Features

- ✅ **Non-root containers:** All containers run as non-root users
- ✅ **Read-only filesystem:** Frontend runs with read-only root filesystem
- ✅ **Drop capabilities:** All Linux capabilities dropped
- ✅ **Security profiles:** Seccomp profiles enforced
- ✅ **Network policies:** Pod-to-pod traffic restricted
- ✅ **PodDisruptionBudgets:** High availability during updates
- ✅ **Resource limits:** CPU/memory limits prevent resource exhaustion
- ✅ **Pod anti-affinity:** Pods spread across nodes

### Audit Security

```bash
# Check security contexts
kubectl get pods -n youlend -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].securityContext}{"\n"}{end}'

# Verify network policies
kubectl get networkpolicies -n youlend

# Check resource limits
kubectl describe pods -n youlend | grep -A 5 "Limits:"
```

## Clean Up

### Delete Application

```bash
# Delete all resources in namespace
kubectl delete namespace youlend

# Or delete individually
kubectl delete -f backend/
kubectl delete -f frontend/
kubectl delete -f ingress.yaml
kubectl delete -f network-policy.yaml
kubectl delete -f secrets.yaml
kubectl delete -f namespace.yaml
```

### Verify Cleanup

```bash
# Check for remaining resources
kubectl get all -n youlend

# Check for PVCs (if any were created)
kubectl get pvc -n youlend
```

## Production Checklist

Before going to production:

- [ ] Update `secrets.yaml` with real Auth0 credentials
- [ ] Configure ACM certificate for HTTPS
- [ ] Set up DNS records pointing to ALB
- [ ] Enable ALB access logs
- [ ] Configure backup strategy (if using persistent storage)
- [ ] Set up monitoring alerts (Prometheus/Grafana)
- [ ] Review and adjust resource limits based on load testing
- [ ] Test autoscaling under load
- [ ] Verify network policies allow required traffic
- [ ] Enable Pod Security Standards
- [ ] Document disaster recovery procedures

## Image URIs

### Backend
```
YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/youlend-backend:latest
YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/youlend-backend:v1.0.0
```

### Frontend
```
YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/youlend-frontend:latest
YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/youlend-frontend:v1.0.0
```

## Next Steps

After deploying to Kubernetes:
1. **Phase 5:** Create Helm charts for easier management
2. **Phase 6:** Provision infrastructure with Terraform
3. **Phase 7:** Set up CI/CD pipeline
4. **Phase 8:** Configure observability (Prometheus/Grafana)
