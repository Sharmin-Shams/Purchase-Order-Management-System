import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthenticationService } from '@services/authentication.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthenticationService);
  const router = inject(Router);

  authService.autoAuthUser()
  const isAuth = authService.getIsAuthenticated();

  if (!isAuth) router.navigate(['/login']);

  return isAuth;
};

export const loginGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthenticationService);
  const router = inject(Router);

  authService.autoAuthUser()

  const isAuth = authService.getIsAuthenticated();

  if (isAuth) {
    router.navigate(['/']);
    return false;
  }

  return true;
};
