export const environment = {
  production: false,
  demoMode: false, // Set to true to run without Auth0
  apiUrl: 'http://localhost:5001/api/v1',
  auth0: {
    domain: 'YOUR_AUTH0_DOMAIN_HERE',  // Replace with your Auth0 domain (e.g., 'dev-abc123.us.auth0.com')
    clientId: 'YOUR_AUTH0_CLIENT_ID_HERE',  // Replace with your Auth0 client ID
    authorizationParams: {
      redirect_uri: 'http://localhost:4200/callback',  
    }
  }
};

// Instructions:
// 1. Copy this file to environment.ts
// 2. Replace YOUR_AUTH0_DOMAIN_HERE with your Auth0 domain
// 3. Replace YOUR_AUTH0_CLIENT_ID_HERE with your Auth0 client ID
// 4. Or set demoMode: true to run without Auth0 setup