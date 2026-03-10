#!/bin/bash

# YouLend ECR Push Script Template
# Copy this file to push-to-ecr.sh and update AWS_ACCOUNT_ID

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - REPLACE WITH YOUR VALUES
AWS_PROFILE="youlend"
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="YOUR_AWS_ACCOUNT_ID_HERE"  # Replace with your AWS Account ID

# Derived configuration
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
BACKEND_REPO="youlend-backend"
FRONTEND_REPO="youlend-frontend"

# Docker image names
BACKEND_IMAGE="$ECR_REGISTRY/$BACKEND_REPO"
FRONTEND_IMAGE="$ECR_REGISTRY/$FRONTEND_REPO"

echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}YouLend ECR Docker Push Script${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""
echo "Configuration:"
echo "  AWS Profile: $AWS_PROFILE"
echo "  AWS Region: $AWS_REGION"
echo "  AWS Account: $AWS_ACCOUNT_ID"
echo "  ECR Registry: $ECR_REGISTRY"
echo ""

# Check if AWS_ACCOUNT_ID is still placeholder
if [[ "$AWS_ACCOUNT_ID" == "YOUR_AWS_ACCOUNT_ID_HERE" ]]; then
    echo -e "${RED}✗ Please update AWS_ACCOUNT_ID in this script${NC}"
    echo "1. Edit this file"
    echo "2. Replace YOUR_AWS_ACCOUNT_ID_HERE with your AWS Account ID"
    echo "3. Or set environment variable: export AWS_ACCOUNT_ID=123456789012"
    exit 1
fi

# Step 1: Verify AWS credentials
echo -e "${YELLOW}[1/8] Verifying AWS credentials...${NC}"
if ! aws sts get-caller-identity --profile $AWS_PROFILE > /dev/null 2>&1; then
    echo -e "${RED}✗ AWS authentication failed${NC}"
    echo "Please configure AWS credentials for profile: $AWS_PROFILE"
    exit 1
fi
echo -e "${GREEN}✓ AWS credentials verified${NC}"

# Step 2: Create ECR repositories if they don't exist
echo -e "${YELLOW}[2/8] Creating ECR repositories...${NC}"

for REPO in $BACKEND_REPO $FRONTEND_REPO; do
    if ! aws ecr describe-repositories \
            --repository-names $REPO \
            --profile $AWS_PROFILE \
            --region $AWS_REGION > /dev/null 2>&1; then
        echo "Creating ECR repository: $REPO"
        aws ecr create-repository \
            --repository-name $REPO \
            --profile $AWS_PROFILE \
            --region $AWS_REGION \
            --image-scanning-configuration scanOnPush=true \
            --tags Key=Project,Value=YouLend Key=Environment,Value=Production > /dev/null
    fi
done

echo -e "${GREEN}✓ ECR repositories ready${NC}"

# Step 3: Authenticate Docker to ECR
echo -e "${YELLOW}[3/8] Authenticating Docker to ECR...${NC}"
aws ecr get-login-password \
    --profile $AWS_PROFILE \
    --region $AWS_REGION | \
    docker login \
    --username AWS \
    --password-stdin "$ECR_REGISTRY" || {
    echo -e "${RED}✗ Docker ECR authentication failed${NC}"
    exit 1
}
echo -e "${GREEN}✓ Docker authenticated to ECR${NC}"

# Step 4: Build backend image
echo -e "${YELLOW}[4/8] Building backend image...${NC}"
cd backend
docker build -t $BACKEND_IMAGE:latest . || {
    echo -e "${RED}✗ Backend build failed${NC}"
    cd ..
    exit 1
}
cd ..
echo -e "${GREEN}✓ Backend image built${NC}"

# Step 5: Build frontend image
echo -e "${YELLOW}[5/8] Building frontend image...${NC}"
cd frontend
docker build -t $FRONTEND_IMAGE:latest . || {
    echo -e "${RED}✗ Frontend build failed${NC}"
    cd ..
    exit 1
}
cd ..
echo -e "${GREEN}✓ Frontend image built${NC}"

# Step 6: Tag images with version
echo -e "${YELLOW}[6/8] Tagging images...${NC}"
VERSION="v1.0.0"
GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

docker tag $BACKEND_IMAGE:latest $BACKEND_IMAGE:$VERSION
docker tag $BACKEND_IMAGE:latest $BACKEND_IMAGE:$GIT_SHA
docker tag $FRONTEND_IMAGE:latest $FRONTEND_IMAGE:$VERSION
docker tag $FRONTEND_IMAGE:latest $FRONTEND_IMAGE:$GIT_SHA

echo -e "${GREEN}✓ Images tagged${NC}"

# Step 7: Push backend images
echo -e "${YELLOW}[7/8] Pushing backend images...${NC}"
docker push $BACKEND_IMAGE:latest
docker push $BACKEND_IMAGE:$VERSION
docker push $BACKEND_IMAGE:$GIT_SHA
echo -e "${GREEN}✓ Backend images pushed${NC}"

# Step 8: Push frontend images
echo -e "${YELLOW}[8/8] Pushing frontend images...${NC}"
docker push $FRONTEND_IMAGE:latest
docker push $FRONTEND_IMAGE:$VERSION
docker push $FRONTEND_IMAGE:$GIT_SHA
echo -e "${GREEN}✓ Frontend images pushed${NC}"

echo ""
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}✅ All images pushed successfully!${NC}"
echo -e "${GREEN}=================================================${NC}"
echo ""
echo "Pushed images:"
echo "Backend:"
echo "  - $BACKEND_IMAGE:latest"
echo "  - $BACKEND_IMAGE:$VERSION"
echo "  - $BACKEND_IMAGE:$GIT_SHA"
echo ""
echo "Frontend:"
echo "  - $FRONTEND_IMAGE:latest"
echo "  - $FRONTEND_IMAGE:$VERSION"
echo "  - $FRONTEND_IMAGE:$GIT_SHA"
echo ""
echo "Next steps:"
echo "1. Deploy to Kubernetes:"
echo "   cd ../helm && helm upgrade --install youlend ./youlend"
echo ""
echo "2. Update image tags in values.yaml if needed"
echo ""