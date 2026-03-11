#!/bin/bash
# Apply Terraform configuration

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Apply Terraform Configuration         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Check if initialized
if [ ! -d ".terraform" ]; then
    echo -e "${RED}✗ Terraform not initialized${NC}"
    echo -e "${YELLOW}Run ./init.sh first${NC}"
    exit 1
fi

# Run plan
echo -e "${YELLOW}[1/2] Running Terraform plan...${NC}"
terraform plan -out=tfplan || {
    echo -e "${RED}✗ Terraform plan failed${NC}"
    exit 1
}
echo -e "${GREEN}✓ Plan created${NC}"

# Confirm apply
echo ""
echo -e "${YELLOW}Review the plan above. Do you want to apply? (yes/no)${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Apply cancelled${NC}"
    rm -f tfplan
    exit 0
fi

# Apply
echo ""
echo -e "${YELLOW}[2/2] Applying Terraform configuration...${NC}"
terraform apply tfplan || {
    echo -e "${RED}✗ Terraform apply failed${NC}"
    rm -f tfplan
    exit 1
}

rm -f tfplan
echo -e "${GREEN}✓ Infrastructure deployed${NC}"

# Get outputs
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Infrastructure Deployed                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Outputs:${NC}"
terraform output

echo ""
echo -e "${YELLOW}Configure kubectl:${NC}"
terraform output -raw configure_kubectl
echo ""

echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Configure kubectl using the command above"
echo "  2. Install AWS Load Balancer Controller"
echo "  3. Deploy application using Helm or kubectl"
echo ""
