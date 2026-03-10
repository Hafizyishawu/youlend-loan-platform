#!/bin/bash
# Initialize Terraform

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Initialize Terraform                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Check if backend is set up
echo -e "${YELLOW}[1/3] Checking backend infrastructure...${NC}"

AWS_PROFILE="youlend"
AWS_REGION="us-east-1"
BUCKET_NAME="terraform-state-youlend-YOUR_AWS_ACCOUNT_ID"
DYNAMODB_TABLE="terraform-state-lock-youlend"

if ! aws s3 ls "s3://${BUCKET_NAME}" --profile "$AWS_PROFILE" --region "$AWS_REGION" > /dev/null 2>&1; then
    echo -e "${RED}✗ S3 bucket does not exist${NC}"
    echo -e "${YELLOW}Run ./setup-backend.sh first${NC}"
    exit 1
fi

if ! aws dynamodb describe-table \
    --table-name "$DYNAMODB_TABLE" \
    --profile "$AWS_PROFILE" \
    --region "$AWS_REGION" > /dev/null 2>&1; then
    echo -e "${RED}✗ DynamoDB table does not exist${NC}"
    echo -e "${YELLOW}Run ./setup-backend.sh first${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Backend infrastructure exists${NC}"

# Initialize Terraform
echo ""
echo -e "${YELLOW}[2/3] Initializing Terraform...${NC}"
terraform init -upgrade || {
    echo -e "${RED}✗ Terraform init failed${NC}"
    exit 1
}
echo -e "${GREEN}✓ Terraform initialized${NC}"

# Validate configuration
echo ""
echo -e "${YELLOW}[3/3] Validating Terraform configuration...${NC}"
terraform validate || {
    echo -e "${RED}✗ Terraform validation failed${NC}"
    exit 1
}
echo -e "${GREEN}✓ Configuration valid${NC}"

# Success
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Terraform Initialized                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Review terraform.tfvars (or create from terraform.tfvars.example)"
echo "  2. Run: terraform plan"
echo "  3. Run: terraform apply"
echo ""
