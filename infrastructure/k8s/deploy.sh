#!/bin/bash
# Deploy YouLend application to Kubernetes

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Deploy YouLend to Kubernetes              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Configuration
NAMESPACE="youlend"
CONTEXT="${1:-$(kubectl config current-context)}"

echo -e "${BLUE}Configuration:${NC}"
echo "  Namespace: $NAMESPACE"
echo "  Context: $CONTEXT"
echo ""

# Verify kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl not found${NC}"
    echo "Please install kubectl: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Verify context
echo -e "${YELLOW}[1/9] Verifying Kubernetes context...${NC}"
kubectl config use-context "$CONTEXT" > /dev/null || {
    echo -e "${RED}✗ Failed to set context${NC}"
    exit 1
}
echo -e "${GREEN}✓ Context set: $CONTEXT${NC}"

# Create namespace
echo ""
echo -e "${YELLOW}[2/9] Creating namespace...${NC}"
kubectl apply -f namespace.yaml
echo -e "${GREEN}✓ Namespace created/updated${NC}"

# Apply secrets
echo ""
echo -e "${YELLOW}[3/9] Applying secrets...${NC}"
echo -e "${YELLOW}⚠${NC}  Note: Update secrets.yaml with actual Auth0 credentials before production use"
kubectl apply -f secrets.yaml
echo -e "${GREEN}✓ Secrets applied${NC}"

# Apply ConfigMaps
echo ""
echo -e "${YELLOW}[4/9] Applying ConfigMaps...${NC}"
kubectl apply -f backend/configmap.yaml
echo -e "${GREEN}✓ ConfigMaps applied${NC}"

# Deploy backend
echo ""
echo -e "${YELLOW}[5/9] Deploying backend...${NC}"
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/service.yaml
kubectl apply -f backend/hpa.yaml
kubectl apply -f backend/pdb.yaml
echo -e "${GREEN}✓ Backend deployed${NC}"

# Deploy frontend
echo ""
echo -e "${YELLOW}[6/9] Deploying frontend...${NC}"
kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/service.yaml
kubectl apply -f frontend/hpa.yaml
kubectl apply -f frontend/pdb.yaml
echo -e "${GREEN}✓ Frontend deployed${NC}"

# Apply network policies
echo ""
echo -e "${YELLOW}[7/9] Applying network policies...${NC}"
kubectl apply -f network-policy.yaml
echo -e "${GREEN}✓ Network policies applied${NC}"

# Deploy ingress
echo ""
echo -e "${YELLOW}[8/9] Deploying ingress...${NC}"
kubectl apply -f ingress.yaml
echo -e "${GREEN}✓ Ingress deployed${NC}"

# Wait for rollout
echo ""
echo -e "${YELLOW}[9/9] Waiting for deployments to be ready...${NC}"

kubectl rollout status deployment/backend -n "$NAMESPACE" --timeout=300s || {
    echo -e "${RED}✗ Backend deployment failed${NC}"
    kubectl get pods -n "$NAMESPACE" -l app=backend
    exit 1
}
echo -e "${GREEN}✓ Backend ready${NC}"

kubectl rollout status deployment/frontend -n "$NAMESPACE" --timeout=300s || {
    echo -e "${RED}✗ Frontend deployment failed${NC}"
    kubectl get pods -n "$NAMESPACE" -l app=frontend
    exit 1
}
echo -e "${GREEN}✓ Frontend ready${NC}"

# Display status
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Deployment Successful                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}Resources:${NC}"
kubectl get all -n "$NAMESPACE"

echo ""
echo -e "${GREEN}Ingress:${NC}"
kubectl get ingress -n "$NAMESPACE"

echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Get ingress URL:"
echo "     kubectl get ingress -n $NAMESPACE"
echo ""
echo "  2. Watch pods:"
echo "     kubectl get pods -n $NAMESPACE -w"
echo ""
echo "  3. View logs:"
echo "     kubectl logs -n $NAMESPACE -l app=backend --tail=50"
echo "     kubectl logs -n $NAMESPACE -l app=frontend --tail=50"
echo ""
echo "  4. Access application:"
echo "     The ALB DNS will be shown in the ingress output above"
echo ""
