import { NgClass, NgForOf, NgIf } from '@angular/common';
import { Component, OnDestroy, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { Department } from '@models/department.model';
import { Employee } from '@models/employee.model';
import { AuthenticationService } from '@services/authentication.service';
import { DepartmentService } from '@services/department.service';
import { EmployeeService } from '@services/employee.service';
import { handleApiErrors, handleFormErrors } from '@utils/error-handler';
import { requiredMinMaxLengthTrimmed } from '@validators/form.validators';
import { ToastrService } from 'ngx-toastr';
import { Observable, Subject, switchMap, takeUntil } from 'rxjs';

@Component({
  selector: 'app-update-department',
  imports: [ReactiveFormsModule, NgForOf, NgClass, NgIf],
  templateUrl: './update-department.component.html',
  styleUrl: './update-department.component.scss',
  standalone: true,
})
export class UpdateDepartmentComponent implements OnInit, OnDestroy {
  department: Department | null;
  departments$: Observable<Department[]>;
  departmentForm: FormGroup;

  private destroy$ = new Subject<void>();
  private user: Employee;

  constructor(
    private fb: FormBuilder,
    private deptService: DepartmentService,
    private toastr: ToastrService,
    private api: EmployeeService,
    private auth: AuthenticationService
  ) {}

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  ngOnInit(): void {
    this.departmentForm = this.fb.group({
      id: [null],
      rowVersion: [''],
      name: [null, [requiredMinMaxLengthTrimmed(3, 128)]],
      description: [null, [requiredMinMaxLengthTrimmed(null, 512)]],
      invocationDate: [null],
    });

    const userId = this.auth.getUserId();
    if (userId) {
      this.api
        .getEmployee(userId)
        .pipe(
          takeUntil(this.destroy$),
          switchMap((emp) => {
            this.user = emp ?? null;
            return this.deptService.getAllWithDetails();
          })
        )
        .subscribe({
          next: (depts) => {
            if (depts && this.user?.departmentID) {
              this.department = depts.find(
                (d) => d.id == this.user!.departmentID
              )!;
              this.setFormValues();
            }
          },
          error: (e) => handleApiErrors(e, this.toastr),
        });
    }
  }

  getControlError(controlName: string, displayName: string) {
    const control = this.departmentForm.get(controlName);
    if (control && control.touched && control.invalid) {
      const errors = control.errors;
      if (errors) {
        return Object.keys(errors).map((key) => {
          if (key === 'required') return `${displayName} is required.`;
          if (key === 'minlength') return `${displayName} is too short.`;
          if (key === 'maxlength')
            return `${displayName} must not exceed ${errors[key]['requiredLength']} characters.`;
          if (key === 'dateInPast')
            return `${displayName} cannot be in the past.`;
          if (key === 'invalidDate') return `${displayName} is invalid.`;
          if (key === 'fieldError') return errors['fieldError'];
        });
      }
    }
    return [];
  }

  onSubmit(): void {
    if (this.departmentForm.invalid) {
      this.departmentForm.markAllAsTouched();
      return;
    }

    this.deptService
      .update(this.departmentForm.value)
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (r) => {
          this.departmentForm.reset();
          this.loadDepartments();
          this.toastr.success(r.message ?? 'Successfully updated department.');
        },
        error: (e) => {
          handleFormErrors(this.departmentForm, e, this.toastr);
        },
      });
  }

  onFormReset() {
    this.departmentForm.reset();
    this.setFormValues();
  }

  private loadDepartments() {
    this.deptService
      .getAllWithDetails()
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (depts) => {
          if (depts && this.user?.departmentID) {
            this.department = depts.find(
              (d) => d.id == this.user!.departmentID
            )!;
            this.setFormValues();
          }
        },
        error: (e) => handleApiErrors(e, this.toastr),
      });
  }

  private setFormValues() {
    this.departmentForm.patchValue({
      id: this.department?.id,
      rowVersion: this.department?.rowVersion,
      name: this.department?.name,
      description: this.department?.description,
      invocationDate: this.department?.invocationDate?.split('T')[0] ?? null,
    });
  }

  get id() {
    return this.departmentForm.get('id');
  }

  get name() {
    return this.departmentForm.get('name');
  }

  get description() {
    return this.departmentForm.get('description');
  }

  get invocationDate() {
    return this.departmentForm.get('invocationDate');
  }
}
