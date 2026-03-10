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
  if (req.url.includes('auth0.com')) {
    return next(req);
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
