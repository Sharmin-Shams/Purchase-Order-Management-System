import { AsyncPipe, NgClass, NgForOf, NgIf } from '@angular/common';
import { Component, OnDestroy, OnInit } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import {
  PASSWORD_REGEX,
  PHONE_REGEX,
  POSTAL_REGEX,
  SIN_REGEX,
} from '@constants/constants';
import { DepartmentDto } from '@models/department.model';
import { EmployeeDto } from '@models/employee.model';
import { Job } from '@models/job.model';
import { DepartmentService } from '@services/department.service';
import { EmployeeService } from '@services/employee.service';
import { JobService } from '@services/job.service';
import { handleFormErrors } from '@utils/error-handler';
import { getLocalDate } from '@utils/helpers';
import {
  dateAfterValidator,
  minimumAgeValidator,
  requiredMinMaxLengthTrimmed,
} from '@validators/form.validators';
import { ToastrService } from 'ngx-toastr';
import { Observable, Subject, takeUntil } from 'rxjs';
import { merge } from 'rxjs';

@Component({
  selector: 'app-create-employee',
  imports: [ReactiveFormsModule, NgIf, NgClass, NgForOf, AsyncPipe],
  templateUrl: './create-employee.component.html',
  styleUrl: './create-employee.component.scss',
  standalone: true,
})
export class CreateEmployeeComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();
  departments$: Observable<DepartmentDto[]>;
  supervisors$: Observable<EmployeeDto[]>;
  jobs: Job[];
  employeeForm: FormGroup;
  TODAY = getLocalDate();

  constructor(
    private deptService: DepartmentService,
    private empService: EmployeeService,
    private jobService: JobService,
    private toastr: ToastrService,
    private fb: FormBuilder
  ) {}

  ngOnInit(): void {
    this.departments$ = this.deptService.getAll();
    this.supervisors$ = this.empService.getAllSupervisors();

    this.employeeForm = this.fb.group(
      {
        password: [
          '',
          [Validators.required, Validators.pattern(PASSWORD_REGEX)],
        ],
        firstName: ['', [requiredMinMaxLengthTrimmed(2, 50)]],
        lastName: ['', [requiredMinMaxLengthTrimmed(3, 50)]],
        middleInitial: [null],
        streetAddress: ['', requiredMinMaxLengthTrimmed()],
        city: ['', requiredMinMaxLengthTrimmed()],
        postalCode: [
          '',
          [Validators.required, Validators.pattern(POSTAL_REGEX)],
        ],
        doB: ['', [Validators.required, minimumAgeValidator(16)]],
        sin: ['', [Validators.required, Validators.pattern(SIN_REGEX)]],
        seniorityDate: ['', Validators.required],
        jobStartDate: ['', Validators.required],
        workPhone: ['', [Validators.required, Validators.pattern(PHONE_REGEX)]],
        cellPhone: ['', [Validators.required, Validators.pattern(PHONE_REGEX)]],
        email: [
          '',
          [Validators.required, Validators.email, Validators.maxLength(255)],
        ],
        isSupervisor: [null],
        supervisorID: [null],
        departmentID: [null],
        jobID: [null, Validators.required],
        officeLocation: ['', requiredMinMaxLengthTrimmed()],
      },
      {
        validators: dateAfterValidator(
          'seniorityDate',
          'jobStartDate',
          'jobStartDate'
        ),
      }
    );

    this.jobService
      .getAll()
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (res) => (this.jobs = res),
      });

    this.form
      .get('jobID')
      ?.valueChanges.pipe(takeUntil(this.destroy$))
      .subscribe((jobId: number) => {
        const job = this.jobs.find((j) => j.id == jobId);
        const isCEO = job?.name.trim().toUpperCase() === 'CEO';
        const ctrls = [this.supervisor, this.department];

        ctrls.forEach((ctrl) => {
          if (job && isCEO) ctrl?.reset();
          else ctrl?.setValidators([Validators.required]);
          isCEO ? ctrl?.disable() : ctrl?.enable();
          ctrl?.updateValueAndValidity();
        });
      });

    merge(
      this.department!.valueChanges,
      this.form.get('isSupervisor')!.valueChanges
    )
      .pipe(takeUntil(this.destroy$))
      .subscribe(() => {
        if (this.supervisor?.errors) {
          this.supervisor.setErrors(null);
          this.supervisor.updateValueAndValidity();
        }
      });
  }

  onSubmit() {
    if (this.employeeForm.invalid) {
      this.employeeForm.markAllAsTouched();
      return;
    }

    this.empService.create(this.employeeForm.value).subscribe({
      next: (r) => {
        this.toastr.success(r.message ?? 'Successfully created employee.');
        this.supervisors$ = this.empService.getAllSupervisors();
        this.employeeForm.reset();
      },
      error: (e) => {
        handleFormErrors(this.employeeForm, e, this.toastr);
      },
    });
  }

  getControlError(controlName: string, displayName: string, to?: string) {
    const control = this.employeeForm.get(controlName);
    if (control && control.touched && control.invalid) {
      const errors = control.errors;
      if (errors) {
        return Object.keys(errors).map((key) => {
          if (key === 'required') return `${displayName} is required.`;
          if (key === 'minlength') return `${displayName} is too short.`;
          if (key === 'maxlength')
            return `${displayName} must not exceed ${errors[key]['requiredLength']} characters.`;
          if (key === 'dateNotBefore')
            return `${displayName} cannot be before seniority date.`;
          if (key === 'invalidDate' || key === 'email')
            return `${displayName} is invalid.`;
          if (key === 'age')
            return `Age must be ${errors[key]['requiredAge']} and above.`;
          if (key === 'invalidDateOrder')
            return `${displayName} must not be prior than ${to}.`;
          if (key === 'fieldError') return errors['fieldError'];
        });
      }
    }
    return [];
  }

  get form() {
    return this.employeeForm;
  }

  get supervisor() {
    return this.form.get('supervisorID');
  }

  get department() {
    return this.form.get('departmentID');
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
