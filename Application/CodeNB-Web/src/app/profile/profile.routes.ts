import { Route } from '@angular/router';
import { ViewComponent } from './view/view.component';
import { UpdateProfileComponent } from './update-profile/update-profile.component';
import { UpdateDepartmentComponent } from './update-department/update-department.component';
import { roleGuard } from '@guards/role.guard';
import { UserRole } from '@constants/constants';

export default [
  {
    path: '',
    component: ViewComponent,
  },
  {
    path: 'update',
    component: UpdateProfileComponent,
  },
  {
    path: 'department/update',
    component: UpdateDepartmentComponent,
    canActivate: [roleGuard],
    data: {
      allowedRoles: [
        UserRole.HRSupervisor,
        UserRole.RegularSupervisor,
      ],
    },
  },
] satisfies Route[];
