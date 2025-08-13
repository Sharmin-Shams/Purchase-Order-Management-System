import { Route } from '@angular/router';
import { ViewComponent } from './view/view.component';
import { DetailsComponent } from './details/details.component';
import { CreateComponent } from './create/create.component';
import { EditComponent } from './edit/edit.component';
import { SearchComponent } from './search/search.component';
import { UserRole } from '@constants/constants';
import { roleGuard } from '@guards/role.guard';
import { SearchSupervisorComponent } from './search-supervisor/search-supervisor.component';
import { ReviewSupervisorComponent } from './review-supervisor/review-supervisor.component';

export default [
  {
    path: '',
    component: ViewComponent,
  },
  {
    path: 'create',
    component: CreateComponent,
  },
  {
    path: 'details/:id',
    component: DetailsComponent,
  },
  {
    path: 'details/:id',
    component: DetailsComponent,
  },
  {
    path: 'edit/:id',
    component: EditComponent,
  },
  {
    path: 'search',
    component: SearchComponent
  },
  {
    path: 'supervisor',
    component: SearchSupervisorComponent,
     canActivate: [roleGuard],
        data: {
          allowedRoles: [
           // UserRole.CEO,
           // UserRole.RegularEmployee,
            UserRole.RegularSupervisor,
            UserRole.HRSupervisor
          ],
        },
  },
  {
    path: 'review/:id',
    component: ReviewSupervisorComponent
  },

] satisfies Route[];
