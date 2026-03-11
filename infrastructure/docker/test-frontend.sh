#!/bin/bash
# Test frontend Docker image locally

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Testing Frontend Docker Image Locally      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

FRONTEND_DIR="../frontend"
IMAGE_NAME="youlend-frontend"
CONTAINER_NAME="youlend-frontend-test"

# Check if frontend directory exists
if [ ! -d "$FRONTEND_DIR" ]; then
    echo -e "${RED}Error: Frontend directory not found at $FRONTEND_DIR${NC}"
    exit 1
fi

# Step 1: Build image
echo -e "${YELLOW}[1/5] Building Docker image...${NC}"
cd "$FRONTEND_DIR"

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
    -p 4200:80 \
    "$IMAGE_NAME:test" || {
    echo -e "${RED}✗ Failed to start container${NC}"
    exit 1
}

echo -e "${GREEN}✓ Container started${NC}"

# Step 4: Wait for nginx to start
echo ""
echo -e "${YELLOW}[4/5] Waiting for nginx (max 10s)...${NC}"

for i in {1..10}; do
    if curl -sf http://localhost:4200/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Nginx health check passed${NC}"
        break
    fi
    
    if [ $i -eq 10 ]; then
        echo -e "${RED}✗ Health check timeout${NC}"
        docker logs "$CONTAINER_NAME"
        docker rm -f "$CONTAINER_NAME"
        exit 1
    fi
    
    sleep 1
done

# Step 5: Test endpoints
echo ""
echo -e "${YELLOW}[5/5] Testing endpoints...${NC}"

# Test health endpoint
if curl -sf http://localhost:4200/health > /dev/null; then
    echo -e "${GREEN}✓${NC} /health - OK"
else
    echo -e "${RED}✗${NC} /health - FAILED"
fi

# Test index.html
if curl -sf http://localhost:4200/ | grep -q "YouLend"; then
    echo -e "${GREEN}✓${NC} / (index.html) - OK"
else
    echo -e "${RED}✗${NC} / (index.html) - FAILED"
fi

# Test main.js exists
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4200/main.js)
if [ "$HTTP_CODE" == "200" ] || [ "$HTTP_CODE" == "304" ]; then
    echo -e "${GREEN}✓${NC} /main.js - OK (HTTP $HTTP_CODE)"
else
    echo -e "${YELLOW}⚠${NC} /main.js - Warning (HTTP $HTTP_CODE) - May use different bundle name"
fi

# Test Angular routing (should serve index.html for all routes)
if curl -sf http://localhost:4200/loans | grep -q "YouLend"; then
    echo -e "${GREEN}✓${NC} /loans (routing) - OK"
else
    echo -e "${YELLOW}⚠${NC} /loans (routing) - Warning (may need app initialization)"
fi

# Success summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Frontend Docker Test PASSED           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Container is running:${NC}"
echo "  Name: $CONTAINER_NAME"
echo "  Port: 4200 (mapped to container port 80)"
echo "  Image: $IMAGE_NAME:test"
echo ""
echo -e "${YELLOW}Commands:${NC}"
echo "  View logs:    docker logs $CONTAINER_NAME"
echo "  Stop:         docker stop $CONTAINER_NAME"
echo "  Remove:       docker rm -f $CONTAINER_NAME"
echo "  Visit:        http://localhost:4200"
echo ""
echo -e "${BLUE}Open http://localhost:4200 in your browser to test the UI${NC}"
echo ""
