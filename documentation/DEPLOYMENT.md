# Deployment Guide

Complete guide for deploying the YouLend Loan Management Platform to AWS.

## Prerequisites

- AWS Account (ID: YOUR_AWS_ACCOUNT_ID)
- AWS CLI configured with profile `youlend`
- Docker installed
- kubectl 1.28+
- Helm 3.x
- Terraform 1.6+
- Git

## Deployment Options

### Option 1: Full Automated Deployment (Recommended)

**Time**: ~45 minutes

```bash
# 1. Clone repository
git clone https://github.com/Hafizyishawu/youlend-loan-platform.git
cd youlend-loan-platform

# 2. Setup Terraform backend
cd infrastructure/terraform
./setup-backend.sh

# 3. Deploy infrastructure
./init.sh
./apply.sh

# 4. Configure kubectl
$(terraform output -raw configure_kubectl)

# 5. Push Docker images to ECR
cd ../docker
./push-to-ecr.sh v1.0.0

# 6. Install monitoring stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack \
  -f ../monitoring/prometheus-values.yaml \
  -n monitoring --create-namespace

helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki-stack \
  -f ../monitoring/loki-values.yaml \
  -n monitoring

# 7. Deploy application
cd ../helm
helm install youlend ./youlend -f youlend/values-prod.yaml

# 8. Verify deployment
kubectl get all -n youlend
kubectl get ingress -n youlend
```

### Option 2: GitHub Actions Deployment

**Prerequisites**: GitHub secrets configured

```bash
# Trigger infrastructure deployment
git push origin main  # (if terraform changes)

# Trigger application deployment (production)
# Go to GitHub Actions → Deploy to Production
# Enter version: v1.0.0
# Click "Run workflow"
# Approve deployment
```

### Option 3: Manual Step-by-Step

See sections below for detailed manual deployment.

## Step-by-Step Manual Deployment

### 1. Setup AWS Infrastructure

**Create VPC, EKS, ECR:**

```bash
cd infrastructure/terraform

# Initialize
terraform init

# Review plan
terraform plan

# Apply
terraform apply

# Save outputs
terraform output > outputs.txt
```

**Configure kubectl:**

```bash
aws eks update-kubeconfig \
  --name youlend-eks \
  --region us-east-1 \
  --profile youlend

# Verify
kubectl get nodes
```

### 2. Build and Push Docker Images

```bash
# Backend
cd backend
docker build -t youlend-backend:v1.0.0 .
docker tag youlend-backend:v1.0.0 \
  YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/youlend-backend:v1.0.0

# Frontend
cd ../frontend
docker build -t youlend-frontend:v1.0.0 .
docker tag youlend-frontend:v1.0.0 \
  YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/youlend-frontend:v1.0.0

# Login to ECR
aws ecr get-login-password --region us-east-1 --profile youlend | \
  docker login --username AWS --password-stdin \
  YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Push
docker push YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/youlend-backend:v1.0.0
docker push YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/youlend-frontend:v1.0.0
```

### 3. Deploy Monitoring Stack

```bash
# Prometheus + Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack \
  -f infrastructure/monitoring/prometheus-values.yaml \
  -n monitoring --create-namespace

# Loki
helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki-stack \
  -f infrastructure/monitoring/loki-values.yaml \
  -n monitoring

# ServiceMonitors
kubectl apply -f infrastructure/monitoring/servicemonitor-backend.yaml
kubectl apply -f infrastructure/monitoring/servicemonitor-frontend.yaml
```

### 4. Deploy Application

**Using Helm:**

```bash
cd infrastructure/helm
helm install youlend ./youlend \
  --set backend.image.tag=v1.0.0 \
  --set frontend.image.tag=v1.0.0 \
  -f youlend/values-prod.yaml
```

**Using kubectl:**

```bash
cd infrastructure/k8s
kubectl apply -f namespace.yaml
kubectl apply -f secrets.yaml
kubectl apply -f backend/
kubectl apply -f frontend/
kubectl apply -f ingress.yaml
kubectl apply -f network-policy.yaml
```

### 5. Verify Deployment

```bash
# Check pods
kubectl get pods -n youlend

# Check services
kubectl get svc -n youlend

# Check ingress
kubectl get ingress -n youlend

# Get ALB URL
kubectl get ingress youlend-ingress -n youlend \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Check logs
kubectl logs -n youlend -l app=backend --tail=50
```

## Configuration

### Update Auth0 Credentials

```bash
# Method 1: Helm
helm upgrade youlend ./youlend \
  --set secrets.auth0.domain=your-domain.auth0.com \
  --set secrets.auth0.clientId=your-client-id \
  -f youlend/values-prod.yaml

# Method 2: kubectl
kubectl edit secret auth0-credentials -n youlend
# Update values (base64 encoded)
```

### Configure Custom Domain

```bash
# 1. Request ACM certificate
aws acm request-certificate \
  --domain-name youlend.example.com \
  --validation-method DNS \
  --region us-east-1

# 2. Update ingress
helm upgrade youlend ./youlend \
  --set ingress.certificateArn=arn:aws:acm:... \
  --set ingress.hosts[0].host=youlend.example.com

# 3. Create Route53 record pointing to ALB
```

## Troubleshooting

### Pods Not Starting

```bash
kubectl describe pod <pod-name> -n youlend
kubectl logs <pod-name> -n youlend
kubectl get events -n youlend --sort-by='.lastTimestamp'
```

### Ingress Not Working

```bash
# Check ALB creation
kubectl describe ingress youlend-ingress -n youlend

# Check ALB controller
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

### Database Connection Issues

```bash
# Check secrets
kubectl get secret -n youlend
kubectl describe secret auth0-credentials -n youlend

# Test connectivity
kubectl run -it --rm debug --image=busybox --restart=Never -- \
  wget -O- http://backend/health/live
```

## Rollback

### Helm Rollback

```bash
# List releases
helm history youlend -n youlend

# Rollback
helm rollback youlend -n youlend

# Rollback to specific revision
helm rollback youlend 5 -n youlend
```

### Manual Rollback

```bash
# Re-deploy previous version
kubectl set image deployment/backend \
  backend=YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/youlend-backend:v0.9.0 \
  -n youlend
```

## Monitoring Access

```bash
# Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Access: http://localhost:3000
# Login: admin / CHANGE_ME_SECURE_PASSWORD

# Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Loki (via Grafana datasource)
```

## Cleanup

```bash
# Delete application
helm uninstall youlend -n youlend

# Delete monitoring
helm uninstall prometheus -n monitoring
helm uninstall loki -n monitoring

# Delete infrastructure
cd infrastructure/terraform
./destroy.sh

# Delete backend (optional)
aws s3 rb s3://terraform-state-youlend-YOUR_AWS_ACCOUNT_ID --force
aws dynamodb delete-table --table-name terraform-state-lock-youlend
```

## Production Checklist

Before going to production:

- [ ] Update Auth0 credentials
- [ ] Configure ACM certificate for HTTPS
- [ ] Set up custom domain and DNS
- [ ] Review and adjust resource limits
- [ ] Configure alert receivers (Slack/Email)
- [ ] Set up backup strategy
- [ ] Document disaster recovery procedures
- [ ] Load test the application
- [ ] Security audit completed
- [ ] Runbook created for on-call

## Support

For deployment issues:
- Check logs: `kubectl logs -n youlend -l app=backend`
- Check events: `kubectl get events -n youlend`
- Review CloudTrail for AWS API errors
- Contact: abdulyishawu333@gmail.com
