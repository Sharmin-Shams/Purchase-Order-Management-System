import { Route } from '@angular/router';
import { ViewComponent } from './view/view.component';
import { CreateEmployeeComponent } from './create-employee/create-employee.component';
import { CreateDepartmentComponent } from './create-department/create-department.component';
import { SearchEmployeeComponent } from './search-employee/search-employee.component';
import { UpdateDepartmentComponent } from './update-department/update-department.component';
import { UpdateEmployeeComponent } from './update-employee/update-employee.component';
import { DeleteDepartmentComponent } from './delete-department/delete-department.component';

export default [
  {
    path: '',
    component: ViewComponent,
  },
  {
    path: 'employees/create',
    component: CreateEmployeeComponent,
  },
  {
    path: 'employees/search',
    component: SearchEmployeeComponent,
  },
  {
    path: 'employees/update/:id',
    component: UpdateEmployeeComponent,
  },
  {
    path: 'departments/create',
    component: CreateDepartmentComponent,
  },
  {
    path: 'departments/update',
    component: UpdateDepartmentComponent,
  },
  {
    path: 'departments/delete',
    component: DeleteDepartmentComponent,
  },
] satisfies Route[];
