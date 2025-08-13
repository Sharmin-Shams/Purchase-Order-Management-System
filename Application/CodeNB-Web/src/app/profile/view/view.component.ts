import { Component, OnDestroy, OnInit } from '@angular/core';
import { RouterLink } from '@angular/router';
import { UserRole } from '@constants/constants';
import { Employee } from '@models/employee.model';
import { Job } from '@models/job.model';
import { AuthenticationService } from '@services/authentication.service';
import { EmployeeService } from '@services/employee.service';
import { JobService } from '@services/job.service';
import { handleApiErrors } from '@utils/error-handler';
import { isSupervisorExceptCEO } from '@utils/helpers';
import { ToastrService } from 'ngx-toastr';
import { Subject, switchMap, takeUntil } from 'rxjs';

@Component({
  selector: 'profile-view',
  imports: [RouterLink],
  templateUrl: './view.component.html',
  styleUrl: './view.component.scss',
})
export class ViewComponent implements OnInit, OnDestroy {
  employee: Employee | null;
  job: Job | null;
  isSupervisor: boolean;
  isCEO: boolean;

  private destroy$ = new Subject<void>();
  constructor(
    private api: EmployeeService,
    private auth: AuthenticationService,
    private jobSvc: JobService,
    private toastr: ToastrService
  ) {}

  ngOnInit(): void {
    const user = this.auth.getUser();
    if (user) {
      this.isSupervisor = isSupervisorExceptCEO(user.role);
      this.isCEO = user.role.trim() == UserRole.CEO;

      this.api
        .getEmployee(user.id)
        .pipe(
          takeUntil(this.destroy$),
          switchMap((emp) => {
            this.employee = emp ?? null;
            return this.jobSvc.getAll();
          })
        )
        .subscribe({
          next: (jobs) => {
            if (jobs && this.employee?.jobID) {
              this.job = jobs.find((j) => j.id == this.employee!.jobID) ?? null;
            }
          },
          error: (e) => handleApiErrors(e, this.toastr),
        });
    }
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
