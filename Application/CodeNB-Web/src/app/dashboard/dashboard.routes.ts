import { Route } from '@angular/router';
import { DashboardRedirectComponent } from './dashboard-redirect.component';
import { ViewPendingReviewsComponent } from './view-pending-reviews/view-pending-reviews.component';
import { roleGuard } from '@guards/role.guard';
import { UserRole } from '@constants/constants';
import { ViewReviewsComponent } from './view-reviews/view-reviews.component';

export default [
  {
    path: '',
    component: DashboardRedirectComponent,
  },
  {
    path: 'reviews/pending',
    component: ViewPendingReviewsComponent,
    canActivate: [roleGuard],
    data: {
      allowedRoles: [
        UserRole.CEO,
        UserRole.HRSupervisor,
        UserRole.RegularSupervisor,
      ],
    },
  },
  {
    path: 'reviews',
    component: ViewReviewsComponent,
  },
] satisfies Route[];
