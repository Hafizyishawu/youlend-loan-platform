#!/bin/bash
# Push Docker images to AWS ECR

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Push Docker Images to AWS ECR             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Configuration
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-YOUR_AWS_ACCOUNT_ID_HERE}"
AWS_REGION="us-east-1"
AWS_PROFILE="youlend"
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Image configuration
BACKEND_REPO="youlend-backend"
FRONTEND_REPO="youlend-frontend"
VERSION="${1:-latest}"  # Use first argument or 'latest'
GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "local")

echo -e "${BLUE}Configuration:${NC}"
echo "  AWS Account: $AWS_ACCOUNT_ID"
echo "  AWS Region: $AWS_REGION"
echo "  AWS Profile: $AWS_PROFILE"
echo "  ECR Registry: $ECR_REGISTRY"
echo "  Version Tag: $VERSION"
echo "  Git SHA: $GIT_SHA"
echo ""

# Step 1: Verify AWS credentials
echo -e "${YELLOW}[1/8] Verifying AWS credentials...${NC}"
aws sts get-caller-identity --profile "$AWS_PROFILE" > /dev/null || {
    echo -e "${RED}✗ AWS authentication failed${NC}"
    echo "Please configure AWS credentials for profile: $AWS_PROFILE"
    exit 1
}
echo -e "${GREEN}✓ AWS credentials verified${NC}"

# Step 2: Create ECR repositories if they don't exist
echo ""
echo -e "${YELLOW}[2/8] Creating ECR repositories...${NC}"

for REPO in "$BACKEND_REPO" "$FRONTEND_REPO"; do
    if aws ecr describe-repositories \
        --repository-names "$REPO" \
        --region "$AWS_REGION" \
        --profile "$AWS_PROFILE" > /dev/null 2>&1; then
        echo -e "${BLUE}ℹ${NC} Repository exists: $REPO"
    else
        aws ecr create-repository \
            --repository-name "$REPO" \
            --region "$AWS_REGION" \
            --profile "$AWS_PROFILE" \
            --image-scanning-configuration scanOnPush=true \
            --encryption-configuration encryptionType=AES256 \
            --tags Key=Project,Value=YouLend Key=Environment,Value=Production > /dev/null
        echo -e "${GREEN}✓${NC} Created repository: $REPO"
    fi
done

# Step 3: Authenticate Docker to ECR
echo ""
echo -e "${YELLOW}[3/8] Authenticating Docker to ECR...${NC}"
aws ecr get-login-password \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE" | \
    docker login \
    --username AWS \
    --password-stdin "$ECR_REGISTRY" || {
    echo -e "${RED}✗ Docker ECR authentication failed${NC}"
    exit 1
}
echo -e "${GREEN}✓ Docker authenticated to ECR${NC}"

# Step 4: Build backend image
echo ""
echo -e "${YELLOW}[4/8] Building backend image...${NC}"
cd ../backend
docker build -t "$BACKEND_REPO:$VERSION" . || {
    echo -e "${RED}✗ Backend build failed${NC}"
    exit 1
}
echo -e "${GREEN}✓ Backend image built${NC}"

# Step 5: Build frontend image
echo ""
echo -e "${YELLOW}[5/8] Building frontend image...${NC}"
cd ../frontend
docker build -t "$FRONTEND_REPO:$VERSION" . || {
    echo -e "${RED}✗ Frontend build failed${NC}"
    exit 1
}
echo -e "${GREEN}✓ Frontend image built${NC}"

# Step 6: Tag images for ECR
echo ""
echo -e "${YELLOW}[6/8] Tagging images for ECR...${NC}"

# Backend tags
docker tag "$BACKEND_REPO:$VERSION" "$ECR_REGISTRY/$BACKEND_REPO:$VERSION"
docker tag "$BACKEND_REPO:$VERSION" "$ECR_REGISTRY/$BACKEND_REPO:$GIT_SHA"
docker tag "$BACKEND_REPO:$VERSION" "$ECR_REGISTRY/$BACKEND_REPO:latest"

# Frontend tags
docker tag "$FRONTEND_REPO:$VERSION" "$ECR_REGISTRY/$FRONTEND_REPO:$VERSION"
docker tag "$FRONTEND_REPO:$VERSION" "$ECR_REGISTRY/$FRONTEND_REPO:$GIT_SHA"
docker tag "$FRONTEND_REPO:$VERSION" "$ECR_REGISTRY/$FRONTEND_REPO:latest"

echo -e "${GREEN}✓ Images tagged${NC}"

# Step 7: Push backend images
echo ""
echo -e "${YELLOW}[7/8] Pushing backend images to ECR...${NC}"
docker push "$ECR_REGISTRY/$BACKEND_REPO:$VERSION"
docker push "$ECR_REGISTRY/$BACKEND_REPO:$GIT_SHA"
docker push "$ECR_REGISTRY/$BACKEND_REPO:latest"
echo -e "${GREEN}✓ Backend images pushed${NC}"

# Step 8: Push frontend images
echo ""
echo -e "${YELLOW}[8/8] Pushing frontend images to ECR...${NC}"
docker push "$ECR_REGISTRY/$FRONTEND_REPO:$VERSION"
docker push "$ECR_REGISTRY/$FRONTEND_REPO:$GIT_SHA"
docker push "$ECR_REGISTRY/$FRONTEND_REPO:latest"
echo -e "${GREEN}✓ Frontend images pushed${NC}"

# Success summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Images Pushed to ECR Successfully      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Backend Images:${NC}"
echo "  $ECR_REGISTRY/$BACKEND_REPO:$VERSION"
echo "  $ECR_REGISTRY/$BACKEND_REPO:$GIT_SHA"
echo "  $ECR_REGISTRY/$BACKEND_REPO:latest"
echo ""
echo -e "${GREEN}Frontend Images:${NC}"
echo "  $ECR_REGISTRY/$FRONTEND_REPO:$VERSION"
echo "  $ECR_REGISTRY/$FRONTEND_REPO:$GIT_SHA"
echo "  $ECR_REGISTRY/$FRONTEND_REPO:latest"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Verify images in AWS Console: https://console.aws.amazon.com/ecr"
echo "  2. Deploy to Kubernetes (Phase 4)"
echo ""
