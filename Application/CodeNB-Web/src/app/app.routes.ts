import { Routes } from '@angular/router';
import { LoginComponent } from './login/login.component';
import { authGuard, loginGuard } from '@guards/auth.guard';
import { MainComponent } from './main/main.component';
import { UserRole } from '@constants/constants';
import { roleGuard } from '@guards/role.guard';

export const routes: Routes = [
  {
    path: '',
    component: MainComponent,
    canActivateChild: [authGuard],
    children: [
      {
        path: '',
        loadChildren: () => import('./dashboard/dashboard.routes'),
      },
      {
        path: 'po',
        loadChildren: () => import('./po/po.routes'),
      },
      {
        path: 'hr',
        loadChildren: () => import('./hr/hr.routes'),
        canActivate: [roleGuard],
        data: {
          allowedRoles: [
            UserRole.CEO,
            UserRole.HRSupervisor,
            UserRole.HREmployee,
          ],
        },
      },
      {
        path: 'profile',
        loadChildren: () => import('./profile/profile.routes'),
      },
    ],
  },
  { path: 'login', component: LoginComponent, canActivate: [loginGuard] },
];
