import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '@auth0/auth0-angular';
import { switchMap, take } from 'rxjs/operators';

/**
 * HTTP interceptor to add JWT token to requests
 */
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);

  // Don't add token to Auth0 requests
  try{
   const authUrl = new URL(req.url, window.location.origin);
    const authHost = authUrl.hostname;

    // Adjust this allow-list to match your actual Auth0 tenant domains
    const auth0AllowedHosts = [
      'auth0.com', // root domain (if ever used directly)
      // Example tenant domain; replace with your real Auth0 tenant:
      // 'your-tenant-region.auth0.com',
    ];

    if (auth0AllowedHosts.includes(authHost)) {
      return next(req);
    }
  } catch {
    // If URL parsing fails, fall through and attach the token
  }	  

  return authService.getAccessTokenSilently().pipe(
    take(1),
    switchMap(token => {
      // Clone request and add authorization header
      const authReq = req.clone({
        setHeaders: {
          Authorization: `Bearer ${token}`
        }
      });
      return next(authReq);
    })
  );
};
