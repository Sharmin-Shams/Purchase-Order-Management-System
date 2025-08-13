import { AsyncPipe, NgClass, NgFor, NgIf } from '@angular/common';
import { Component, OnDestroy, OnInit } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import {
  EMPLOYEE_STATUS,
  EmployeeStatus,
  MIN_AGE,
  PHONE_REGEX,
  POSTAL_REGEX,
  SIN_REGEX,
} from '@constants/constants';
import { DepartmentDto } from '@models/department.model';
import { Employee, EmployeeDto } from '@models/employee.model';
import { Job } from '@models/job.model';
import { DepartmentService } from '@services/department.service';
import { EmployeeService } from '@services/employee.service';
import { JobService } from '@services/job.service';
import { handleApiErrors, handleFormErrors } from '@utils/error-handler';
import {
  clearField,
  getLocalDate,
  setField,
  stripTimezone,
} from '@utils/helpers';
import {
  dateAfterValidator,
  minimumAgeValidator,
  passwordPatternIfChanged,
  requiredMinMaxLengthTrimmed,
} from '@validators/form.validators';
import { ToastrService } from 'ngx-toastr';
import { merge, Observable, Subject, takeUntil } from 'rxjs';

@Component({
  selector: 'app-update-employee',
  imports: [ReactiveFormsModule, AsyncPipe, NgClass, NgIf, NgFor],
  templateUrl: './update-employee.component.html',
  styleUrl: './update-employee.component.scss',
  standalone: true,
})
export class UpdateEmployeeComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();

  employee: Employee;
  employeeForm: FormGroup;
  supervisors$: Observable<EmployeeDto[]>;
  departments$: Observable<DepartmentDto[]>;
  jobs: Job[];

  empStatusEnum = EmployeeStatus;
  EMPLOYEE_STATUS = EMPLOYEE_STATUS;
  TODAY = getLocalDate();

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private api: EmployeeService,
    private toastr: ToastrService,
    private deptApi: DepartmentService,
    private jobApi: JobService,
    private fb: FormBuilder
  ) {}

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (id && !isNaN(+id)) {
      this.initForm();
      this.initValues(+id);

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
    } else {
      this.router.navigate(['/hr/employees/search']);
    }
  }

  onSubmit() {
    if (this.employeeForm.invalid) {
      this.employeeForm.markAllAsTouched();
      return;
    }

    const data: Employee = {
      ...this.employeeForm.getRawValue(),
      password: this.getPassword(),
    };

    this.api.updateEmployee(data).subscribe({
      next: (r) => {
        this.initValues(this.employee.id);
        this.toastr.success(r.message ?? 'Successfully created employee.');
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

  onJobChange() {
    setField(this.form.get('jobStartDate'), this.TODAY);
    this.validateJob();
  }

  onStatusChange() {
    const status = this.status?.value;
    const e = this.employee;

    if (status === EmployeeStatus.RETIRED) {
      setField(
        this.retirementDate,
        e.status == EmployeeStatus.RETIRED
          ? stripTimezone(e.retirementDate) ?? this.TODAY
          : this.TODAY,
        [Validators.required]
      );
      clearField(this.terminationDate);
      setField(this.terminationDate, '');

      setField(
        this.form.get('seniorityDate'),
        stripTimezone(e.seniorityDate) ?? this.TODAY
      );
      setField(
        this.form.get('jobStartDate'),
        stripTimezone(e.jobStartDate) ?? this.TODAY
      );
    } else if (status === EmployeeStatus.TERMINATED) {
      let terminationDate = this.TODAY;

      if (e.status == EmployeeStatus.TERMINATED) {
        terminationDate = stripTimezone(e.terminationDate) ?? this.TODAY;
        setField(
          this.form.get('seniorityDate'),
          stripTimezone(e.seniorityDate) ?? this.TODAY
        );
        setField(
          this.form.get('jobStartDate'),
          stripTimezone(e.jobStartDate) ?? this.TODAY
        );
      }

      setField(this.terminationDate, terminationDate, [Validators.required]);
      clearField(this.retirementDate);
      setField(this.retirementDate, '');
    } else {
      clearField(this.retirementDate);
      clearField(this.terminationDate);
      setField(this.terminationDate, '');
      setField(this.retirementDate, '');

      if (e.status === EmployeeStatus.TERMINATED) {
        setField(this.form.get('seniorityDate'), this.TODAY);
        setField(this.form.get('jobStartDate'), this.TODAY);
      }
    }
  }

  initValues(id: number) {
    this.employeeForm.reset();
    this.departments$ = this.deptApi.getAll();
    this.supervisors$ = this.api.getAllSupervisors();
    this.api.getEmployee(id).subscribe({
      next: (r) => {
        this.employee = r;
        this.initFormValues();
        this.getJobs();
      },
      error: (e) => handleApiErrors(e, this.toastr),
    });
  }

  trackById(index: number, item: Job) {
    return item.id;
  }

  private getJobs() {
    this.jobApi.getAll().subscribe((jobs) => {
      this.jobs = jobs;
      this.validateJob();
    });
  }

  private validateJob() {
    const job = this.jobs?.find((j) => j.id == this.form.get('jobID')?.value);
    const isCEO = job?.name.trim().toUpperCase() === 'CEO';
    const ctrls = [this.supervisor, this.department];

    ctrls.forEach((ctrl) => {
      if (job && isCEO) ctrl?.reset();
      else ctrl?.setValidators([Validators.required]);
      isCEO ? ctrl?.disable() : ctrl?.enable();
      ctrl?.updateValueAndValidity();
    });
  }

  private initForm() {
    this.employeeForm = this.fb.group(
      {
        id: [''],
        rowVersion: [''],
        password: ['', [Validators.required]],
        firstName: ['', [requiredMinMaxLengthTrimmed(2, 50)]],
        lastName: ['', [requiredMinMaxLengthTrimmed(3, 50)]],
        middleInitial: [null],
        streetAddress: ['', requiredMinMaxLengthTrimmed()],
        city: ['', requiredMinMaxLengthTrimmed()],
        postalCode: [
          '',
          [Validators.required, Validators.pattern(POSTAL_REGEX)],
        ],
        doB: ['', [Validators.required, minimumAgeValidator(MIN_AGE)]],
        cellPhone: ['', [Validators.required, Validators.pattern(PHONE_REGEX)]],
        sin: ['', [Validators.required, Validators.pattern(SIN_REGEX)]],
        seniorityDate: ['', Validators.required],
        jobStartDate: ['', Validators.required],
        workPhone: ['', [Validators.required, Validators.pattern(PHONE_REGEX)]],

        email: [
          '',
          [Validators.required, Validators.email, Validators.maxLength(255)],
        ],
        isSupervisor: [null],
        supervisorID: [null],
        departmentID: [null],
        jobID: [null, Validators.required],
        officeLocation: ['', requiredMinMaxLengthTrimmed()],
        status: [''],
        retirementDate: [''],
        terminationDate: [''],
      },
      {
        validators: dateAfterValidator(
          'seniorityDate',
          'jobStartDate',
          'jobStartDate'
        ),
      }
    );
  }

  private initFormValues() {
    const e = this.employee;
    this.employeeForm.patchValue({
      id: e.id,
      rowVersion: e.rowVersion,
      password: e.password.substring(0, 32),
      firstName: e.firstName,
      lastName: e.lastName,
      middleInitial: e.middleInitial,
      streetAddress: e.streetAddress,
      city: e.city,
      postalCode: e.postalCode,
      doB: stripTimezone(e.doB),
      cellPhone: e.cellPhone,

      sin: e.sin,
      seniorityDate: stripTimezone(e.seniorityDate),
      jobStartDate: stripTimezone(e.jobStartDate),
      jobID: e.jobID,
      supervisorID: e.supervisorID,
      departmentID: e.departmentID,
      isSupervisor: e.isSupervisor,
      workPhone: e.workPhone,
      email: e.email,
      officeLocation: e.officeLocation,
      status: e.status,
      retirementDate: stripTimezone(e.retirementDate),
      terminationDate: stripTimezone(e.terminationDate),
    });

    setField(
      this.password,
      this.password?.value,
      passwordPatternIfChanged(e.password.substring(0, 32))
    );

    if (e.status == EmployeeStatus.RETIRED) {
      this.status?.disable();
      this.retirementDate?.disable();
    } else if (e.status == EmployeeStatus.TERMINATED) {
      setField(this.terminationDate, this.terminationDate?.value, [
        Validators.required,
      ]);
    }
  }

  private getPassword() {
    if (
      this.password?.value.substring(0, 32) ===
      this.employee.password?.substring(0, 32)
    )
      return this.employee.password;

    return this.password?.value;
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

  get status() {
    return this.form.get('status');
  }

  get retirementDate() {
    return this.form.get('retirementDate');
  }

  get terminationDate() {
    return this.form.get('terminationDate');
  }

  get password() {
    return this.form.get('password');
  }
}
