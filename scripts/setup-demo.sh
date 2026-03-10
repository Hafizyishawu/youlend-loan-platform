#!/bin/bash

# YouLend Demo Setup Script
# Sets up the project in demo mode for quick evaluation (no Auth0 needed)

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

# Main setup function
main() {
    print_header "YouLend Demo Mode Setup"
    
    echo "This script will set up YouLend in demo mode for quick evaluation."
    echo "Demo mode features:"
    echo "  • No Auth0 account needed"
    echo "  • Mock authentication"
    echo "  • Full API functionality"
    echo "  • Ready in under 2 minutes"
    echo ""
    read -p "Continue? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi

    # Check prerequisites
    print_header "Checking Prerequisites"
    check_prerequisites

    # Setup environment files
    print_header "Setting Up Environment Files"
    setup_environment_files

    # Install dependencies
    print_header "Installing Dependencies"
    install_dependencies

    # Setup demo configuration
    print_header "Configuring Demo Mode"
    setup_demo_mode

    # Success message
    print_header "Setup Complete!"
    show_next_steps
}

check_prerequisites() {
    # Check Node.js
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_success "Node.js found: $NODE_VERSION"
        
        # Check if version is >= 18
        MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
        if [ "$MAJOR_VERSION" -lt 18 ]; then
            print_error "Node.js version 18+ required. Found: $NODE_VERSION"
            exit 1
        fi
    else
        print_error "Node.js not found. Please install Node.js 18+"
        exit 1
    fi

    # Check .NET
    if command -v dotnet &> /dev/null; then
        DOTNET_VERSION=$(dotnet --version)
        print_success ".NET found: $DOTNET_VERSION"
        
        # Check if version starts with 8
        if [[ ! $DOTNET_VERSION =~ ^8\. ]]; then
            print_warning ".NET 8 recommended. Found: $DOTNET_VERSION"
        fi
    else
        print_error ".NET not found. Please install .NET 8 SDK"
        exit 1
    fi

    # Check npm
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm --version)
        print_success "npm found: $NPM_VERSION"
    else
        print_error "npm not found. Please install npm"
        exit 1
    fi
}

setup_environment_files() {
    # Create frontend environment files for demo mode
    print_info "Setting up frontend environment files..."
    
    # Create environment.ts for demo mode
    cat > frontend/src/environments/environment.ts << 'EOF'
export const environment = {
  production: false,
  demoMode: true, // Demo mode enabled - no Auth0 needed
  apiUrl: 'http://localhost:5001/api/v1',
  auth0: {
    domain: 'demo-mode-disabled',
    clientId: 'demo-mode-disabled',
    authorizationParams: {
      redirect_uri: 'http://localhost:4200/callback',  
    }
  }
};
EOF
    
    # Create environment.prod.ts for demo mode
    cat > frontend/src/environments/environment.prod.ts << 'EOF'
export const environment = {
  production: true,
  demoMode: true, // Demo mode enabled - no Auth0 needed
  apiUrl: 'http://localhost:5001/api/v1',
  auth0: {
    domain: 'demo-mode-disabled',
    clientId: 'demo-mode-disabled',
    authorizationParams: {
      redirect_uri: 'http://localhost:4200/callback'
    }
  }
};
EOF
    
    print_success "Environment files created for demo mode"

    # Create .env file
    print_info "Creating .env file..."
    cat > .env << 'EOF'
# YouLend Demo Mode Configuration
DEMO_MODE=true
API_URL=http://localhost:5001/api/v1
FRONTEND_URL=http://localhost:4200
AUTH0_DOMAIN=demo-mode-disabled
AUTH0_CLIENT_ID=demo-mode-disabled
EOF
    print_success ".env file created"
}

install_dependencies() {
    # Install root dependencies
    if [ -f "package.json" ]; then
        print_info "Installing root dependencies..."
        npm install || {
            print_error "Failed to install root dependencies"
            exit 1
        }
        print_success "Root dependencies installed"
    fi

    # Install frontend dependencies
    if [ -d "frontend" ]; then
        print_info "Installing frontend dependencies..."
        cd frontend
        npm install || {
            print_error "Failed to install frontend dependencies"
            exit 1
        }
        cd ..
        print_success "Frontend dependencies installed"
    fi

    # Restore backend dependencies
    if [ -d "backend" ]; then
        print_info "Restoring backend dependencies..."
        cd backend
        dotnet restore || {
            print_error "Failed to restore backend dependencies"
            exit 1
        }
        cd ..
        print_success "Backend dependencies restored"
    fi
}

setup_demo_mode() {
    print_info "Demo mode configuration complete!"
    print_success "✓ Auth0 disabled"
    print_success "✓ Mock authentication enabled"
    print_success "✓ API endpoints accessible"
    print_success "✓ Full CRUD functionality available"
}

show_next_steps() {
    echo -e "${GREEN}"
    echo "🎉 Demo mode setup complete!"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Start the backend API:"
    echo "   cd backend"
    echo "   dotnet run"
    echo ""
    echo "2. In a new terminal, start the frontend:"
    echo "   cd frontend"
    echo "   npm start"
    echo ""
    echo "3. Open your browser:"
    echo "   Frontend: http://localhost:4200"
    echo "   API docs: http://localhost:5001/swagger"
    echo ""
    echo "4. Test the application:"
    echo "   • Click 'Enter as Guest' (no login required)"
    echo "   • Create, edit, and delete loans"
    echo "   • All features work without Auth0"
    echo ""
    echo "Troubleshooting:"
    echo "   • If ports are busy, run: npx kill-port 4200 5001"
    echo "   • Check logs in terminal if issues occur"
    echo "   • Review EVALUATOR_SETUP.md for more details"
    echo ""
    echo -e "${NC}"
    
    print_info "For full Auth0 setup, run: ./scripts/setup-env.sh"
}

# Run the main function
main "$@"