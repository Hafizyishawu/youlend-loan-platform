#!/bin/bash
# Pre-Push Security Sanitization Script
# Run this before pushing to GitHub

set -e

PROJECT_ROOT="$HOME/Documents/youlend/youlend-complete-project"
cd "$PROJECT_ROOT"

echo "🔒 Starting security sanitization..."

# 1. Create comprehensive .gitignore
echo "📝 Creating .gitignore..."
cat > .gitignore << 'EOF'
# === SECRETS - NEVER COMMIT ===
# Environment files with credentials
frontend/src/environments/environment.ts
frontend/src/environments/environment.prod.ts
frontend/src/environments/environment.development.ts

# Terraform sensitive files
infrastructure/terraform/*.tfstate
infrastructure/terraform/*.tfstate.*
infrastructure/terraform/.terraform/
infrastructure/terraform/.terraform.lock.hcl
infrastructure/terraform/terraform.tfvars
infrastructure/terraform/*.auto.tfvars

# AWS credentials
.aws/
*.pem
*.key

# Kubernetes configs
.kube/
kubeconfig
*kubeconfig*

# Helm secrets
infrastructure/helm/**/secrets.yaml
infrastructure/helm/**/values-secrets.yaml

# === Build Outputs ===
# .NET
**/bin/
**/obj/
*.user
*.suo

# Node/Angular
node_modules/
dist/
.angular/
*.log
npm-debug.log*

# Docker
.docker/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Test coverage
coverage/
*.coverage

# Temporary files
*.tmp
*.temp
.env.local
.env.*.local
EOF

# 2. Remove secret files
echo "🗑️  Removing files with secrets..."
rm -f frontend/src/environments/environment.ts
rm -f frontend/src/environments/environment.prod.ts
rm -f infrastructure/terraform/terraform.tfvars
rm -rf infrastructure/terraform/.terraform/
rm -f infrastructure/terraform/.terraform.lock.hcl

# 3. Sanitize Helm values
echo "🧹 Sanitizing Helm values.yaml..."
if [ -f infrastructure/helm/youlend/values.yaml ]; then
    # Backup original
    cp infrastructure/helm/youlend/values.yaml infrastructure/helm/youlend/values.yaml.backup
    
    # Replace sensitive values
    sed -i '' 's/689393245150/<AWS_ACCOUNT_ID>/g' infrastructure/helm/youlend/values.yaml
    sed -i '' 's/youlend\.certifiles\.com/<YOUR_DOMAIN>/g' infrastructure/helm/youlend/values.yaml
fi

# 4. Sanitize ingress template
echo "🧹 Sanitizing Ingress template..."
if [ -f infrastructure/helm/youlend/templates/ingress.yaml ]; then
    cp infrastructure/helm/youlend/templates/ingress.yaml infrastructure/helm/youlend/templates/ingress.yaml.backup
    sed -i '' 's/youlend\.certifiles\.com/<YOUR_DOMAIN>/g' infrastructure/helm/youlend/templates/ingress.yaml
    sed -i '' 's/arn:aws:acm:us-east-1:689393245150:certificate\/[a-f0-9-]*/<ACM_CERTIFICATE_ARN>/g' infrastructure/helm/youlend/templates/ingress.yaml
fi

# 5. Scan for remaining secrets
echo "🔍 Scanning for secrets..."

SECRETS_FOUND=0

# Check for Auth0 client ID
if grep -r "anN4lDPIeRAqA15nZszNupl8PFw6Clac" . --exclude-dir={node_modules,dist,.git,.angular,bin,obj} 2>/dev/null; then
    echo "❌ FOUND: Auth0 Client ID"
    SECRETS_FOUND=1
fi

# Check for Auth0 domain
if grep -r "youlend-assessment\.uk\.auth0\.com" . --exclude-dir={node_modules,dist,.git,.angular,bin,obj} 2>/dev/null; then
    echo "⚠️  FOUND: Auth0 Domain (check if in docs/templates only)"
fi

# Check for AWS account ID (excluding templates)
if grep -r "689393245150" . --exclude-dir={node_modules,dist,.git,.angular,bin,obj} --exclude="*.backup" 2>/dev/null; then
    echo "⚠️  FOUND: AWS Account ID (verify it's in docs/templates only)"
fi

# Check for certificate ARNs
if grep -r "arn:aws:acm:us-east-1:689393245150:certificate" . --exclude-dir={node_modules,dist,.git,.angular,bin,obj} --exclude="*.backup" 2>/dev/null; then
    echo "⚠️  FOUND: Certificate ARN (verify it's been replaced)"
fi

# 6. Verify required template files exist
echo "✅ Verifying template files..."
if [ ! -f frontend/src/environments/environment.template.ts ]; then
    echo "❌ Missing: frontend/src/environments/environment.template.ts"
    SECRETS_FOUND=1
fi

# 7. Final report
echo ""
echo "========================================="
if [ $SECRETS_FOUND -eq 0 ]; then
    echo "✅ SANITIZATION COMPLETE"
    echo "========================================="
    echo ""
    echo "Safe to push! Next steps:"
    echo "1. git add ."
    echo "2. git commit -m 'feat: complete YouLend assessment with EKS deployment'"
    echo "3. git push origin main"
    echo ""
    echo "⚠️  IMPORTANT: Double-check the warnings above before pushing!"
else
    echo "❌ SECRETS DETECTED - DO NOT PUSH"
    echo "========================================="
    echo ""
    echo "Fix the issues above before pushing to GitHub!"
    exit 1
fi
