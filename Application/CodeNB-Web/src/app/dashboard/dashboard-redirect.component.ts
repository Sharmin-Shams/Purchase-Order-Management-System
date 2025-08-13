import { Component, OnInit } from '@angular/core';
import { SupervisorDashboardComponent } from './supervisor-dashboard/supervisor-dashboard.component';
import { EmployeeDashboardComponent } from './employee-dashboard/employee-dashboard.component';
import { AuthenticationService } from '@services/authentication.service';
import { isAllowRole } from '@utils/helpers';
import { UserRole } from '@constants/constants';
import { NgIf } from '@angular/common';

@Component({
  selector: 'app-dashboard-redirect',
  imports: [SupervisorDashboardComponent, EmployeeDashboardComponent, NgIf],
  template: `
    <app-supervisor-dashboard *ngIf="isSupervisor"></app-supervisor-dashboard>
    <app-employee-dashboard *ngIf="!isSupervisor"></app-employee-dashboard>
    
  `,
})
export class DashboardRedirectComponent implements OnInit {
  isSupervisor = false;

  constructor(private auth: AuthenticationService) {}

  ngOnInit(): void {
    const role = this.auth.getRole() ?? null;
    if (role) {
      this.isSupervisor = isAllowRole(
        [UserRole.CEO, UserRole.HRSupervisor, UserRole.RegularSupervisor],
        role
      );
    }
  }
}
