export const environment = {
  production: true,
  demoMode: false,
  apiUrl: '${API_URL}',
  auth0: {
    domain: '${AUTH0_DOMAIN}',
    clientId: '${AUTH0_CLIENT_ID}',
    authorizationParams: {
      redirect_uri: '${REDIRECT_URI}'
    }
  }
};

// Instructions:
// 1. Copy this file to environment.ts
// 2. Replace YOUR_AUTH0_DOMAIN_HERE with your Auth0 domain
// 3. Replace YOUR_AUTH0_CLIENT_ID_HERE with your Auth0 client ID
// 4. Or set demoMode: true to run without Auth0 setup