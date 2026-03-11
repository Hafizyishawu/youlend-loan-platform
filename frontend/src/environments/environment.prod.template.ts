export const environment = {
  production: true,
  demoMode: false, // Set to true to run without Auth0
  apiUrl: 'https://YOUR_DOMAIN_HERE/api/v1',  // Replace with your production domain
  auth0: {
    domain: 'YOUR_AUTH0_DOMAIN_HERE',  // Replace with your Auth0 domain
    clientId: 'YOUR_AUTH0_CLIENT_ID_HERE',  // Replace with your Auth0 client ID
    authorizationParams: {
      redirect_uri: 'https://YOUR_DOMAIN_HERE/callback'  // Replace with your production domain
    }
  }
};

// Instructions:
// 1. Copy this file to environment.prod.ts
// 2. Replace YOUR_DOMAIN_HERE with your production domain
// 3. Replace YOUR_AUTH0_DOMAIN_HERE with your Auth0 domain
// 4. Replace YOUR_AUTH0_CLIENT_ID_HERE with your Auth0 client ID