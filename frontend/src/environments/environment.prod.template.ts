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