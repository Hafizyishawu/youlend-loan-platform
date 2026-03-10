#!/bin/bash
# Setup Terraform backend (S3 + DynamoDB)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Setup Terraform Backend Infrastructure    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Configuration
AWS_REGION="us-east-1"
AWS_PROFILE="youlend"
AWS_ACCOUNT_ID="YOUR_AWS_ACCOUNT_ID"
BUCKET_NAME="terraform-state-youlend-${AWS_ACCOUNT_ID}"
DYNAMODB_TABLE="terraform-state-lock-youlend"

echo -e "${BLUE}Configuration:${NC}"
echo "  AWS Region: $AWS_REGION"
echo "  AWS Profile: $AWS_PROFILE"
echo "  S3 Bucket: $BUCKET_NAME"
echo "  DynamoDB Table: $DYNAMODB_TABLE"
echo ""

# Verify AWS credentials
echo -e "${YELLOW}[1/4] Verifying AWS credentials...${NC}"
aws sts get-caller-identity --profile "$AWS_PROFILE" > /dev/null || {
    echo -e "${RED}✗ AWS authentication failed${NC}"
    exit 1
}
echo -e "${GREEN}✓ AWS credentials verified${NC}"

# Create S3 bucket for state
echo ""
echo -e "${YELLOW}[2/4] Creating S3 bucket for Terraform state...${NC}"

if aws s3 ls "s3://${BUCKET_NAME}" --profile "$AWS_PROFILE" --region "$AWS_REGION" 2>&1 | grep -q 'NoSuchBucket'; then
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$AWS_REGION" \
        --profile "$AWS_PROFILE" || {
        echo -e "${RED}✗ Failed to create S3 bucket${NC}"
        exit 1
    }
    
    # Enable versioning
    aws s3api put-bucket-versioning \
        --bucket "$BUCKET_NAME" \
        --versioning-configuration Status=Enabled \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION"
    
    # Enable encryption
    aws s3api put-bucket-encryption \
        --bucket "$BUCKET_NAME" \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }]
        }' \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION"
    
    # Block public access
    aws s3api put-public-access-block \
        --bucket "$BUCKET_NAME" \
        --public-access-block-configuration \
            "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION"
    
    echo -e "${GREEN}✓ S3 bucket created and configured${NC}"
else
    echo -e "${BLUE}ℹ S3 bucket already exists${NC}"
fi

# Create DynamoDB table for state locking
echo ""
echo -e "${YELLOW}[3/4] Creating DynamoDB table for state locking...${NC}"

if ! aws dynamodb describe-table \
    --table-name "$DYNAMODB_TABLE" \
    --profile "$AWS_PROFILE" \
    --region "$AWS_REGION" > /dev/null 2>&1; then
    
    aws dynamodb create-table \
        --table-name "$DYNAMODB_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION" \
        --tags "Key=Project,Value=youlend" "Key=ManagedBy,Value=Terraform" || {
        echo -e "${RED}✗ Failed to create DynamoDB table${NC}"
        exit 1
    }
    
    echo -e "${GREEN}✓ DynamoDB table created${NC}"
else
    echo -e "${BLUE}ℹ DynamoDB table already exists${NC}"
fi

# Verify setup
echo ""
echo -e "${YELLOW}[4/4] Verifying setup...${NC}"

# Check S3 bucket
if aws s3 ls "s3://${BUCKET_NAME}" --profile "$AWS_PROFILE" --region "$AWS_REGION" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} S3 bucket accessible"
else
    echo -e "${RED}✗${NC} S3 bucket not accessible"
    exit 1
fi

# Check DynamoDB table
if aws dynamodb describe-table \
    --table-name "$DYNAMODB_TABLE" \
    --profile "$AWS_PROFILE" \
    --region "$AWS_REGION" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} DynamoDB table accessible"
else
    echo -e "${RED}✗${NC} DynamoDB table not accessible"
    exit 1
fi

# Success summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Backend Infrastructure Ready             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Resources created:${NC}"
echo "  S3 Bucket: s3://${BUCKET_NAME}"
echo "  DynamoDB Table: ${DYNAMODB_TABLE}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Review backend.tf configuration"
echo "  2. Run: terraform init"
echo "  3. Run: terraform plan"
echo "  4. Run: terraform apply"
echo ""
