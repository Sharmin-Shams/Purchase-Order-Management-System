import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { UserRole } from '@constants/constants';
import { AuthenticationService } from '@services/authentication.service';

export const roleGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthenticationService);
  const router = inject(Router);

  authService.autoAuthUser();

  const allowedRoles: UserRole[] = route.data['allowedRoles'];
  const userRole = authService.getRole();

  if (!userRole) {
    router.navigate(['/']);
    return false;
  }

  const isAllowed = allowedRoles
    .map((role) => role.toLowerCase())
    .includes(userRole?.toLowerCase());

  if (!isAllowed) {
    router.navigate(['/']);
    return false;
  }

  return true;
};
