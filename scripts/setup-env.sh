#!/bin/bash

# YouLend Interactive Environment Setup Script
# Sets up the project with Auth0 configuration for full functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}===============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===============================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Configuration variables
AUTH0_DOMAIN=""
AUTH0_CLIENT_ID=""
API_URL="http://localhost:5001/api/v1"
FRONTEND_URL="http://localhost:4200"
PRODUCTION_DOMAIN=""
DEMO_MODE="false"

main() {
    print_header "YouLend Environment Setup"
    
    echo "This script will help you configure YouLend with your credentials."
    echo ""
    echo "Setup options:"
    echo "  1. Full Auth0 setup (recommended)"
    echo "  2. Demo mode (no Auth0 needed)"
    echo ""
    
    read -p "Choose option (1/2): " -n 1 -r SETUP_OPTION
    echo ""
    
    case $SETUP_OPTION in
        1)
            setup_auth0_flow
            ;;
        2)
            setup_demo_flow
            ;;
        *)
            print_error "Invalid option. Please choose 1 or 2."
            exit 1
            ;;
    esac
}

setup_auth0_flow() {
    print_header "Auth0 Configuration Setup"
    
    echo "You'll need Auth0 credentials. If you don't have them yet:"
    echo "1. Go to https://auth0.com/signup (free account)"
    echo "2. Create a Single Page Application"
    echo "3. Get your Domain and Client ID"
    echo ""
    
    read -p "Do you have Auth0 credentials ready? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Setting up demo mode instead..."
        setup_demo_flow
        return
    fi
    
    # Get Auth0 configuration
    get_auth0_config
    
    # Get other configuration
    get_general_config
    
    # Create environment files
    create_environment_files
    
    # Install dependencies
    install_dependencies
    
    # Show success message
    show_auth0_success
}

setup_demo_flow() {
    print_header "Demo Mode Setup"
    
    DEMO_MODE="true"
    AUTH0_DOMAIN="demo-mode-disabled"
    AUTH0_CLIENT_ID="demo-mode-disabled"
    
    print_info "Demo mode selected - no Auth0 needed!"
    
    # Get basic configuration
    get_general_config
    
    # Create environment files for demo
    create_environment_files
    
    # Install dependencies
    install_dependencies
    
    # Show success message
    show_demo_success
}

get_auth0_config() {
    print_header "Auth0 Configuration"
    
    echo "Please enter your Auth0 application details:"
    echo ""
    
    # Get Auth0 domain
    while [[ -z "$AUTH0_DOMAIN" ]]; do
        echo -e "${BLUE}Auth0 Domain${NC} (e.g., dev-abc123.us.auth0.com):"
        read -r AUTH0_DOMAIN
        
        if [[ -z "$AUTH0_DOMAIN" ]]; then
            print_error "Auth0 domain is required"
        elif [[ ! "$AUTH0_DOMAIN" =~ \.auth0\.com$ ]]; then
            print_warning "Auth0 domain should end with .auth0.com"
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                AUTH0_DOMAIN=""
            fi
        fi
    done
    
    # Get Auth0 client ID
    while [[ -z "$AUTH0_CLIENT_ID" ]]; do
        echo -e "${BLUE}Auth0 Client ID${NC} (alphanumeric string):"
        read -r AUTH0_CLIENT_ID
        
        if [[ -z "$AUTH0_CLIENT_ID" ]]; then
            print_error "Auth0 client ID is required"
        fi
    done
    
    print_success "Auth0 configuration collected"
}

get_general_config() {
    print_header "General Configuration"
    
    echo "API URL (press Enter for default: $API_URL):"
    read -r USER_API_URL
    if [[ -n "$USER_API_URL" ]]; then
        API_URL="$USER_API_URL"
    fi
    
    echo "Frontend URL (press Enter for default: $FRONTEND_URL):"
    read -r USER_FRONTEND_URL
    if [[ -n "$USER_FRONTEND_URL" ]]; then
        FRONTEND_URL="$USER_FRONTEND_URL"
    fi
    
    echo "Production domain (optional, for production deployment):"
    read -r PRODUCTION_DOMAIN
    
    print_success "General configuration collected"
}

create_environment_files() {
    print_header "Creating Environment Files"
    
    # Create frontend environment.ts
    print_info "Creating frontend/src/environments/environment.ts..."
    cat > frontend/src/environments/environment.ts << EOF
export const environment = {
  production: false,
  demoMode: $([[ "$DEMO_MODE" == "true" ]] && echo "true" || echo "false"),
  apiUrl: '$API_URL',
  auth0: {
    domain: '$AUTH0_DOMAIN',
    clientId: '$AUTH0_CLIENT_ID',
    authorizationParams: {
      redirect_uri: '$FRONTEND_URL/callback',  
    }
  }
};
EOF
    
    # Create frontend environment.prod.ts
    print_info "Creating frontend/src/environments/environment.prod.ts..."
    PROD_API_URL="$API_URL"
    PROD_FRONTEND_URL="$FRONTEND_URL"
    
    if [[ -n "$PRODUCTION_DOMAIN" ]]; then
        PROD_API_URL="https://$PRODUCTION_DOMAIN/api/v1"
        PROD_FRONTEND_URL="https://$PRODUCTION_DOMAIN"
    fi
    
    cat > frontend/src/environments/environment.prod.ts << EOF
export const environment = {
  production: true,
  demoMode: $([[ "$DEMO_MODE" == "true" ]] && echo "true" || echo "false"),
  apiUrl: '$PROD_API_URL',
  auth0: {
    domain: '$AUTH0_DOMAIN',
    clientId: '$AUTH0_CLIENT_ID',
    authorizationParams: {
      redirect_uri: '$PROD_FRONTEND_URL/callback'
    }
  }
};
EOF
    
    # Create .env file
    print_info "Creating .env file..."
    cat > .env << EOF
# YouLend Environment Configuration
DEMO_MODE=$DEMO_MODE
API_URL=$API_URL
FRONTEND_URL=$FRONTEND_URL
AUTH0_DOMAIN=$AUTH0_DOMAIN
AUTH0_CLIENT_ID=$AUTH0_CLIENT_ID

# Production Settings
PRODUCTION_DOMAIN=$PRODUCTION_DOMAIN
PRODUCTION_API_URL=$PROD_API_URL

# AWS Configuration (for deployment)
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=123456789012
ECR_REGISTRY=123456789012.dkr.ecr.us-east-1.amazonaws.com
CLUSTER_NAME=youlend-eks

# Monitoring
GRAFANA_ADMIN_PASSWORD=CHANGE_ME_SECURE_PASSWORD
EOF
    
    # Create Grafana values if needed
    if [[ ! -f "infrastructure/monitoring/grafana-values.yaml" ]]; then
        print_info "Creating Grafana configuration..."
        cp infrastructure/monitoring/grafana-values.template.yaml infrastructure/monitoring/grafana-values.yaml
        # Update the password
        sed -i.bak 's/CHANGE_ME_PLEASE/CHANGE_ME_SECURE_PASSWORD/g' infrastructure/monitoring/grafana-values.yaml
        rm -f infrastructure/monitoring/grafana-values.yaml.bak
    fi
    
    print_success "Environment files created"
}

install_dependencies() {
    print_header "Installing Dependencies"
    
    # Install root dependencies
    if [ -f "package.json" ]; then
        print_info "Installing root dependencies..."
        npm install --silent || {
            print_warning "Failed to install root dependencies, continuing..."
        }
        print_success "Root dependencies installed"
    fi

    # Install frontend dependencies
    if [ -d "frontend" ]; then
        print_info "Installing frontend dependencies (this may take a moment)..."
        cd frontend
        npm install --silent || {
            print_error "Failed to install frontend dependencies"
            cd ..
            exit 1
        }
        cd ..
        print_success "Frontend dependencies installed"
    fi

    # Restore backend dependencies
    if [ -d "backend" ]; then
        print_info "Restoring backend dependencies..."
        cd backend
        dotnet restore --nologo --verbosity quiet || {
            print_error "Failed to restore backend dependencies"
            cd ..
            exit 1
        }
        cd ..
        print_success "Backend dependencies restored"
    fi
}

show_auth0_success() {
    print_header "Setup Complete - Auth0 Mode"
    
    echo -e "${GREEN}"
    echo "🎉 Auth0 setup complete!"
    echo ""
    echo "Configuration:"
    echo "  • Auth0 Domain: $AUTH0_DOMAIN"
    echo "  • Auth0 Client ID: $AUTH0_CLIENT_ID"
    echo "  • API URL: $API_URL"
    echo "  • Frontend URL: $FRONTEND_URL"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Start the backend:"
    echo "   cd backend && dotnet run"
    echo ""
    echo "2. Start the frontend (new terminal):"
    echo "   cd frontend && npm start"
    echo ""
    echo "3. Configure Auth0 (if not done yet):"
    echo "   • Allowed Callback URLs: $FRONTEND_URL/callback"
    echo "   • Allowed Logout URLs: $FRONTEND_URL"
    echo "   • Allowed Web Origins: $FRONTEND_URL"
    echo ""
    echo "4. Test the application:"
    echo "   • Open: $FRONTEND_URL"
    echo "   • Click 'Login' → Auth0 login flow"
    echo "   • Test loan management features"
    echo ""
    echo -e "${NC}"
}

show_demo_success() {
    print_header "Setup Complete - Demo Mode"
    
    echo -e "${GREEN}"
    echo "🎉 Demo mode setup complete!"
    echo ""
    echo "Configuration:"
    echo "  • Demo Mode: Enabled"
    echo "  • Auth0: Disabled (mock authentication)"
    echo "  • API URL: $API_URL"
    echo "  • Frontend URL: $FRONTEND_URL"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Start the backend:"
    echo "   cd backend && dotnet run"
    echo ""
    echo "2. Start the frontend (new terminal):"
    echo "   cd frontend && npm start"
    echo ""
    echo "3. Test the application:"
    echo "   • Open: $FRONTEND_URL"
    echo "   • Click 'Enter as Guest' (no login required)"
    echo "   • Test all loan management features"
    echo ""
    echo "Note: To switch to Auth0 mode later, run this script again."
    echo ""
    echo -e "${NC}"
}

# Check if we're in the right directory
if [[ ! -f "package.json" ]] || [[ ! -d "frontend" ]] || [[ ! -d "backend" ]]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Run the main function
main "$@"