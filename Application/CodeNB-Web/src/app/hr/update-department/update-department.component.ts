import { AsyncPipe, NgClass, NgForOf, NgIf } from '@angular/common';
import { Component, OnDestroy, OnInit } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { Department } from '@models/department.model';
import { DepartmentService } from '@services/department.service';
import { handleFormErrors } from '@utils/error-handler';
import { stripTimezone } from '@utils/helpers';
import {
  invocationDateValidator,
  requiredMinMaxLengthTrimmed,
} from '@validators/form.validators';
import { ToastrService } from 'ngx-toastr';
import { Observable, Subject } from 'rxjs';

@Component({
  selector: 'app-update-department',
  imports: [ReactiveFormsModule, AsyncPipe, NgForOf, NgClass, NgIf],
  templateUrl: './update-department.component.html',
  styleUrl: './update-department.component.scss',
  standalone: true,
})
export class UpdateDepartmentComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();
  departments$: Observable<Department[]>;
  departmentForm: FormGroup;
  originalInvocationDate: string | null = null;

  constructor(
    private fb: FormBuilder,
    private deptService: DepartmentService,
    private toastr: ToastrService
  ) {}

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  ngOnInit(): void {
    this.departmentForm = this.fb.group({
      id: [''],
      rowVersion: [''],
      name: [null, [requiredMinMaxLengthTrimmed(3, 128)]],
      description: [null, [requiredMinMaxLengthTrimmed(null, 512)]],
      invocationDate: [null],
    });

    this.init();
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

    this.deptService.update(this.departmentForm.value).subscribe({
      next: (r) => {
        this.onFormReset()
        this.toastr.success(r.message ?? 'Successfully updated department.');
      },
      error: (e) => {
        handleFormErrors(this.departmentForm, e, this.toastr);
      },
    });
  }

  onFormReset() {
    this.departmentForm.reset();
    this.init();
  }

  loadDepartment(id: number) {
    this.departments$.subscribe((depts) => {
      const selectedDept = depts.find((d) => d.id === id);
      if (selectedDept) {
        this.originalInvocationDate = stripTimezone(
          selectedDept.invocationDate
        );

        this.departmentForm.patchValue({
          id: selectedDept.id,
          rowVersion: selectedDept.rowVersion,
          name: selectedDept.name,
          description: selectedDept.description,
          invocationDate: this.originalInvocationDate,
        });

        this.invocationDate?.setValidators([
          Validators.required,
          invocationDateValidator(() => this.originalInvocationDate),
        ]);

        this.invocationDate?.updateValueAndValidity();
        this.departmentForm.enable();
      } else {
        this.disableEnableControls();
      }
    });
  }

  private init() {
    this.id?.setValue('');
    this.departments$ = this.deptService.getAllWithDetails();
    this.disableEnableControls();
  }

  private disableEnableControls() {
    Object.keys(this.departmentForm.controls).forEach((key) => {
      if (key !== 'id') {
        this.departmentForm.get(key)?.disable();
      } else {
        this.departmentForm.get(key)?.enable();
      }
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
