#!/bin/bash
# Destroy Terraform infrastructure

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${RED}╔════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║      DESTROY Terraform Infrastructure         ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${RED}WARNING: This will destroy ALL infrastructure!${NC}"
echo ""

# Check if initialized
if [ ! -d ".terraform" ]; then
    echo -e "${RED}✗ Terraform not initialized${NC}"
    exit 1
fi

# Show plan
echo -e "${YELLOW}[1/2] Running Terraform destroy plan...${NC}"
terraform plan -destroy || {
    echo -e "${RED}✗ Terraform plan failed${NC}"
    exit 1
}

# Confirm destroy
echo ""
echo -e "${RED}Are you ABSOLUTELY SURE you want to destroy all resources?${NC}"
echo -e "${YELLOW}Type 'destroy-all' to confirm:${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "destroy-all" ]; then
    echo -e "${YELLOW}Destroy cancelled${NC}"
    exit 0
fi

# Destroy
echo ""
echo -e "${YELLOW}[2/2] Destroying infrastructure...${NC}"
terraform destroy -auto-approve || {
    echo -e "${RED}✗ Terraform destroy failed${NC}"
    exit 1
}

echo ""
echo -e "${GREEN}✓ Infrastructure destroyed${NC}"
echo ""
echo -e "${YELLOW}Note: Backend resources (S3, DynamoDB) are NOT deleted${NC}"
echo -e "${YELLOW}To remove backend, manually delete:${NC}"
echo "  - S3 bucket: terraform-state-youlend-YOUR_AWS_ACCOUNT_ID"
echo "  - DynamoDB table: terraform-state-lock-youlend"
echo ""
