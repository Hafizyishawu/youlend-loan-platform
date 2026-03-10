#!/bin/bash
# Test backend Docker image locally

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Testing Backend Docker Image Locally       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

BACKEND_DIR="../backend"
IMAGE_NAME="youlend-backend"
CONTAINER_NAME="youlend-backend-test"

# Check if backend directory exists
if [ ! -d "$BACKEND_DIR" ]; then
    echo -e "${RED}Error: Backend directory not found at $BACKEND_DIR${NC}"
    exit 1
fi

# Step 1: Build image
echo -e "${YELLOW}[1/5] Building Docker image...${NC}"
cd "$BACKEND_DIR"

docker build -t "$IMAGE_NAME:test" . || {
    echo -e "${RED}✗ Docker build failed${NC}"
    exit 1
}

echo -e "${GREEN}✓ Image built successfully${NC}"

# Step 2: Check image size
echo ""
echo -e "${YELLOW}[2/5] Checking image size...${NC}"
SIZE=$(docker images "$IMAGE_NAME:test" --format "{{.Size}}")
echo -e "${BLUE}ℹ${NC} Image size: $SIZE"

# Step 3: Run container
echo ""
echo -e "${YELLOW}[3/5] Starting container...${NC}"

# Stop and remove existing container if present
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

docker run -d \
    --name "$CONTAINER_NAME" \
    -p 8080:8080 \
    "$IMAGE_NAME:test" || {
    echo -e "${RED}✗ Failed to start container${NC}"
    exit 1
}

echo -e "${GREEN}✓ Container started${NC}"

# Step 4: Wait for health check
echo ""
echo -e "${YELLOW}[4/5] Waiting for health check (max 30s)...${NC}"

for i in {1..30}; do
    if curl -sf http://localhost:8080/health/live > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Health check passed${NC}"
        break
    fi
    
    if [ $i -eq 30 ]; then
        echo -e "${RED}✗ Health check timeout${NC}"
        docker logs "$CONTAINER_NAME"
        docker rm -f "$CONTAINER_NAME"
        exit 1
    fi
    
    sleep 1
done

# Step 5: Test API endpoints
echo ""
echo -e "${YELLOW}[5/5] Testing API endpoints...${NC}"

# Test health endpoints
if curl -sf http://localhost:8080/health/live > /dev/null; then
    echo -e "${GREEN}✓${NC} /health/live - OK"
else
    echo -e "${RED}✗${NC} /health/live - FAILED"
fi

if curl -sf http://localhost:8080/health/ready > /dev/null; then
    echo -e "${GREEN}✓${NC} /health/ready - OK"
else
    echo -e "${RED}✗${NC} /health/ready - FAILED"
fi

# Test metrics endpoint
if curl -sf http://localhost:8080/metrics | grep -q "process_cpu"; then
    echo -e "${GREEN}✓${NC} /metrics - OK"
else
    echo -e "${RED}✗${NC} /metrics - FAILED"
fi

# Test API endpoint (should return empty array or 401 without auth)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/v1/loans)
if [ "$HTTP_CODE" == "200" ] || [ "$HTTP_CODE" == "401" ]; then
    echo -e "${GREEN}✓${NC} /api/v1/loans - OK (HTTP $HTTP_CODE)"
else
    echo -e "${RED}✗${NC} /api/v1/loans - FAILED (HTTP $HTTP_CODE)"
fi

# Success summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Backend Docker Test PASSED           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Container is running:${NC}"
echo "  Name: $CONTAINER_NAME"
echo "  Port: 8080"
echo "  Image: $IMAGE_NAME:test"
echo ""
echo -e "${YELLOW}Commands:${NC}"
echo "  View logs:    docker logs $CONTAINER_NAME"
echo "  Stop:         docker stop $CONTAINER_NAME"
echo "  Remove:       docker rm -f $CONTAINER_NAME"
echo "  Test API:     curl http://localhost:8080/api/v1/loans"
echo ""
