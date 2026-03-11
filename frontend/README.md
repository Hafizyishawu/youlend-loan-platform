# YouLend Loan Management Frontend

Production-grade Angular 17 SPA with Auth0 authentication and Material Design.

## Features

✅ **Complete CRUD Operations**
- List all loans with search
- Create new loans
- View loan details
- Edit existing loans
- Delete loans with confirmation

✅ **Authentication**
- Auth0 integration
- Route protection with guards
- JWT token management
- Login/logout flow

✅ **Production Features**
- Angular 17 standalone components
- Material Design UI
- Reactive forms with validation
- HTTP interceptors (auth, error, loading)
- Global error handling
- Loading indicators
- Toast notifications
- Responsive design (mobile + desktop)
- Environment-specific configs
- Unit tests

✅ **UI/UX**
- Clean, modern interface
- Search and filter
- Confirmation dialogs
- Real-time validation
- Error messages
- Loading states
- Mobile-friendly

## Tech Stack

- Angular 17.1.0 (standalone)
- @angular/material 17.1.0
- @auth0/auth0-angular 2.2.0
- RxJS 7.8.0
- TypeScript 5.3.0
- Nginx (production)

## Quick Start

### Prerequisites
- Node.js 18+ 
- npm 9+

### Installation

```bash
cd frontend
npm install
```

### Configuration

Update `src/environments/environment.ts`:

```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api/v1',
  auth0: {
    domain: 'YOUR_AUTH0_DOMAIN',
    clientId: 'YOUR_AUTH0_CLIENT_ID',
    authorizationParams: {
      redirect_uri: window.location.origin + '/callback',
      audience: 'https://youlend-loan-api'
    }
  }
};
```

### Development Server

```bash
npm start
```

Navigate to `http://localhost:4200`

### Build

```bash
# Development build
npm run build

# Production build
npm run build:prod
```

### Run Tests

```bash
# Run tests once
npm test

# Run tests with coverage
npm run test:ci
```

### Docker

```bash
# Build image
docker build -t youlend-frontend .

# Run container
docker run -p 80:80 youlend-frontend
```

Application available at: `http://localhost`

## Project Structure

```
src/
├── app/
│   ├── core/                      # Singleton services, guards, interceptors
│   │   ├── guards/
│   │   │   └── auth.guard.ts
│   │   ├── interceptors/
│   │   │   ├── auth.interceptor.ts
│   │   │   ├── error.interceptor.ts
│   │   │   └── loading.interceptor.ts
│   │   ├── models/
│   │   │   └── loan.model.ts
│   │   └── services/
│   │       ├── auth.service.ts
│   │       ├── error-handler.service.ts
│   │       ├── loading.service.ts
│   │       └── loan.service.ts
│   │
│   ├── features/                  # Feature modules
│   │   ├── auth/
│   │   │   ├── login/
│   │   │   └── callback/
│   │   └── loans/
│   │       ├── loan-list/
│   │       ├── loan-create/
│   │       ├── loan-detail/
│   │       └── loan-edit/
│   │
│   ├── shared/                    # Shared components, pipes
│   │   ├── components/
│   │   │   ├── navbar/
│   │   │   ├── loading-spinner/
│   │   │   └── confirm-dialog/
│   │   └── pipes/
│   │       └── currency-format.pipe.ts
│   │
│   ├── app.component.ts
│   ├── app.config.ts
│   └── app.routes.ts
│
└── environments/                  # Environment configs
    ├── environment.ts
    └── environment.prod.ts
```

## Auth0 Setup

1. **Create Auth0 Application:**
   - Go to Auth0 Dashboard
   - Create new Single Page Application
   - Note the Domain and Client ID

2. **Configure Allowed URLs:**
   - Allowed Callback URLs: `http://localhost:4200/callback, http://localhost/callback`
   - Allowed Logout URLs: `http://localhost:4200, http://localhost`
   - Allowed Web Origins: `http://localhost:4200, http://localhost`

3. **Create API:**
   - Create API with identifier: `https://youlend-loan-api`
   - Enable RBAC if needed

4. **Update Environment:**
   - Copy Domain to `environment.auth0.domain`
   - Copy Client ID to `environment.auth0.clientId`

## API Integration

Frontend connects to backend API at:
- Development: `http://localhost:8080/api/v1`
- Production: Configure in `environment.prod.ts`

All API calls:
- POST /api/v1/loans - Create loan
- GET /api/v1/loans - Get all loans
- GET /api/v1/loans/{id} - Get loan by ID
- GET /api/v1/loans/search?borrowerName={name} - Search
- PUT /api/v1/loans/{id} - Update loan
- DELETE /api/v1/loans/{id} - Delete loan

## Available Scripts

- `npm start` - Start dev server
- `npm run build` - Build for development
- `npm run build:prod` - Build for production
- `npm test` - Run unit tests
- `npm run test:ci` - Run tests in CI mode
- `npm run watch` - Build and watch for changes

## Testing

Unit tests use Jasmine + Karma:

```bash
# Run all tests
npm test

# Run with coverage
npm run test:ci
```

Test files follow pattern: `*.spec.ts`

## Responsive Design

- Mobile-first approach
- Breakpoints:
  - Mobile: < 600px
  - Tablet: 600px - 960px
  - Desktop: > 960px

## Security

- Auth0 authentication
- JWT token in Authorization header
- HTTP-only approach (no localStorage)
- Route guards protect authenticated routes
- CORS configured
- Security headers in nginx
- Input validation on all forms
- XSS protection

## Performance

- Lazy loading (standalone components)
- AOT compilation
- Tree shaking
- Minification
- Gzip compression
- Static asset caching
- Production build size: ~500KB

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## Troubleshooting

### Auth0 Login Fails
- Check Auth0 domain and client ID
- Verify callback URLs in Auth0 dashboard
- Check browser console for errors

### API Calls Fail
- Ensure backend is running
- Check apiUrl in environment config
- Verify CORS settings in backend
- Check browser network tab

### Build Errors
- Delete node_modules and reinstall
- Clear Angular cache: `rm -rf .angular`
- Check Node version: `node -v` (should be 18+)

## License

MIT
