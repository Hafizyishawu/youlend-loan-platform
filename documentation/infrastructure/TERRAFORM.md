# Terraform Infrastructure

Production-ready Infrastructure as Code for the YouLend Loan Management Platform.

## Overview

This Terraform configuration provisions a complete AWS infrastructure including:

- **VPC**: Multi-AZ VPC with public and private subnets
- **EKS**: Managed Kubernetes cluster with auto-scaling node groups
- **ECR**: Container image registries
- **IAM**: Roles and policies for EKS and services
- **Networking**: Internet Gateway, NAT Gateways, Route Tables
- **Security**: Security groups, VPC Flow Logs
- **State Management**: S3 backend with DynamoDB locking

## Architecture

```
VPC (10.0.0.0/16)
├── Public Subnets (3 AZs)
│   ├── 10.0.1.0/24 (us-east-1a)
│   ├── 10.0.2.0/24 (us-east-1b)
│   └── 10.0.3.0/24 (us-east-1c)
├── Private Subnets (3 AZs)
│   ├── 10.0.10.0/24 (us-east-1a)
│   ├── 10.0.11.0/24 (us-east-1b)
│   └── 10.0.12.0/24 (us-east-1c)
├── Internet Gateway
├── NAT Gateways (3)
└── EKS Cluster
    └── Node Group (t3.medium, 3-10 nodes)
```

## Prerequisites

- Terraform >= 1.6.0
- AWS CLI configured with profile `youlend`
- AWS Account ID: YOUR_AWS_ACCOUNT_ID
- Sufficient AWS permissions to create VPC, EKS, ECR, IAM resources

## Module Structure

```
terraform/
├── main.tf                 # Root module with module calls
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── providers.tf            # Provider configuration
├── backend.tf              # S3 backend configuration
├── versions.tf             # Terraform and provider versions
├── terraform.tfvars.example # Example variables
├── modules/
│   ├── vpc/                # VPC module
│   ├── eks/                # EKS module
│   └── ecr/                # ECR module
├── setup-backend.sh        # Create S3 + DynamoDB
├── init.sh                 # Initialize Terraform
├── apply.sh                # Apply infrastructure
└── destroy.sh              # Destroy infrastructure
```

## Quick Start

### 1. Setup Backend (One-time)

```bash
cd infrastructure/terraform
chmod +x *.sh

# Create S3 bucket and DynamoDB table for state
./setup-backend.sh
```

### 2. Initialize Terraform

```bash
./init.sh
```

### 3. Configure Variables

```bash
# Copy example and customize
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

### 4. Deploy Infrastructure

```bash
./apply.sh
```

This will:
1. Run `terraform plan`
2. Show resources to be created
3. Ask for confirmation
4. Apply the configuration

## Manual Workflow

If you prefer manual control:

```bash
# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply

# Destroy
terraform destroy
```

## Configuration

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Project name | `youlend` |
| `environment` | Environment | `production` |
| `aws_region` | AWS region | `us-east-1` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `cluster_version` | Kubernetes version | `1.28` |
| `node_instance_types` | Node instance types | `["t3.medium"]` |
| `node_desired_size` | Desired node count | `3` |
| `node_min_size` | Minimum node count | `3` |
| `node_max_size` | Maximum node count | `10` |

See [variables.tf](variables.tf) for all variables.

### Environment-Specific Configuration

**Development:**
```hcl
environment        = "development"
single_nat_gateway = true  # Cost savings
node_desired_size  = 1
node_min_size      = 1
node_max_size      = 3
```

**Production:**
```hcl
environment        = "production"
single_nat_gateway = false  # HA with 3 NAT gateways
node_desired_size  = 3
node_min_size      = 3
node_max_size      = 10
```

## Outputs

After applying, Terraform provides these outputs:

```bash
# View all outputs
terraform output

# View specific output
terraform output cluster_endpoint

# Get kubectl config command
terraform output -raw configure_kubectl
```

### Key Outputs

- `vpc_id` - VPC ID
- `cluster_name` - EKS cluster name
- `cluster_endpoint` - EKS API endpoint
- `ecr_repository_urls` - ECR repository URLs
- `configure_kubectl` - Command to configure kubectl

## Post-Deployment

### 1. Configure kubectl

```bash
# Run the output command
$(terraform output -raw configure_kubectl)

# Verify connection
kubectl get nodes
```

### 2. Install AWS Load Balancer Controller

```bash
# Add Helm repo
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Get OIDC provider ARN
OIDC_ARN=$(terraform output -raw oidc_provider_arn)

# Install controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$(terraform output -raw cluster_name) \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### 3. Deploy Application

```bash
# Using Helm
cd ../helm
helm install youlend ./youlend

# Or using kubectl
cd ../k8s
kubectl apply -f .
```

## Modules

### VPC Module

Creates:
- VPC with DNS enabled
- 3 public subnets (one per AZ)
- 3 private subnets (one per AZ)
- Internet Gateway
- NAT Gateways (1 or 3 based on configuration)
- Route tables and associations
- VPC Flow Logs

### EKS Module

Creates:
- EKS cluster (v1.28)
- Managed node group
- OIDC provider for IRSA
- IAM roles and policies
- Security groups
- EKS add-ons (VPC CNI, CoreDNS, kube-proxy)
- IAM role for AWS Load Balancer Controller

### ECR Module

Creates:
- ECR repositories
- Lifecycle policies (keep last 10 images)
- Image scanning enabled
- Encryption enabled (AES256)
- Repository policies

## State Management

### Backend Configuration

State is stored in:
- **S3 Bucket**: `terraform-state-youlend-YOUR_AWS_ACCOUNT_ID`
- **DynamoDB Table**: `terraform-state-lock-youlend`

Features:
- ✅ Versioning enabled
- ✅ Encryption at rest (AES256)
- ✅ State locking via DynamoDB
- ✅ Public access blocked

### State Commands

```bash
# Show state
terraform show

# List resources
terraform state list

# Show specific resource
terraform state show module.vpc.aws_vpc.main

# Pull state
terraform state pull > state.json
```

## Cost Optimization

### Development Environment

To reduce costs in dev:

```hcl
single_nat_gateway = true   # Use 1 NAT instead of 3
node_instance_types = ["t3.small"]
node_desired_size = 1
node_max_size = 3
```

**Estimated monthly cost**: ~$150-200

### Production Environment

High availability configuration:

```hcl
single_nat_gateway = false  # 3 NAT gateways
node_instance_types = ["t3.medium"]
node_desired_size = 3
node_max_size = 10
```

**Estimated monthly cost**: ~$400-600

## Security

### IAM Roles

- **EKS Cluster Role**: Manages EKS control plane
- **Node Group Role**: Allows nodes to join cluster
- **ALB Controller Role**: Manages ALB via IRSA

### Security Groups

- **Cluster SG**: Controls cluster API access
- **Node SG**: Managed by EKS automatically

### Encryption

- ✅ VPC Flow Logs encrypted
- ✅ ECR images encrypted (AES256)
- ✅ Terraform state encrypted
- ✅ EKS secrets encrypted (default)

## Troubleshooting

### Terraform Init Fails

```bash
# Backend not created
./setup-backend.sh

# Re-initialize
terraform init -reconfigure
```

### Plan Shows Unexpected Changes

```bash
# Refresh state
terraform refresh

# Compare
terraform plan
```

### Apply Fails

```bash
# Check AWS credentials
aws sts get-caller-identity --profile youlend

# Check quotas
aws service-quotas list-service-quotas \
  --service-code eks \
  --region us-east-1
```

### State Lock

If state is locked:

```bash
# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

## Maintenance

### Upgrade Terraform

```bash
# Update Terraform
brew upgrade terraform  # macOS

# Re-initialize
terraform init -upgrade
```

### Upgrade Kubernetes

```bash
# Update cluster_version in variables.tf
cluster_version = "1.29"

# Plan and apply
terraform plan
terraform apply
```

### Add Resources

1. Modify Terraform code
2. Run `terraform plan`
3. Review changes
4. Run `terraform apply`

## Cleanup

### Destroy Infrastructure

```bash
./destroy.sh
```

**Warning**: This destroys all resources except S3/DynamoDB backend.

### Remove Backend (Optional)

```bash
# Delete S3 bucket
aws s3 rb s3://terraform-state-youlend-YOUR_AWS_ACCOUNT_ID --force --profile youlend

# Delete DynamoDB table
aws dynamodb delete-table \
  --table-name terraform-state-lock-youlend \
  --profile youlend \
  --region us-east-1
```

## CI/CD Integration

For automated deployments:

```yaml
# GitHub Actions example
- name: Terraform Init
  run: terraform init

- name: Terraform Plan
  run: terraform plan -out=tfplan

- name: Terraform Apply
  run: terraform apply tfplan
```

## Support

For issues:
- Check module READMEs: `modules/*/README.md`
- Review AWS documentation
- Check Terraform registry docs

## License

See main repository for license information.
