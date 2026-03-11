export const environment = {
  production: false,
  demoMode: false,
  apiUrl: '/api/v1',  // Relative URL for tests
  auth0: {
    domain: 'test.auth0.com',
    clientId: 'test-client-id',
    authorizationParams: {
      redirect_uri: 'http://localhost:4200/callback'
    }
  }
};