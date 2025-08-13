import { NgClass, NgForOf, NgIf } from '@angular/common';
import { Component, OnDestroy, OnInit } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { DepartmentService } from '@services/department.service';
import { handleFormErrors } from '@utils/error-handler';
import { getLocalDate } from '@utils/helpers';
import {
  dateNotInPastValidator,
  requiredMinMaxLengthTrimmed,
} from '@validators/form.validators';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-create-department',
  imports: [ReactiveFormsModule, NgClass, NgIf, NgForOf],
  templateUrl: './create-department.component.html',
  styleUrl: './create-department.component.scss',
  standalone: true,
})
export class CreateDepartmentComponent implements OnInit, OnDestroy {
  departmentForm: FormGroup;
  TODAY = getLocalDate();

  constructor(
    private fb: FormBuilder,
    private deptService: DepartmentService,
    private toastr: ToastrService
  ) {}

  ngOnInit(): void {
    this.departmentForm = this.fb.group({
      name: ['', [requiredMinMaxLengthTrimmed(3, 128)]],
      description: ['', [requiredMinMaxLengthTrimmed(null, 512)]],
      invocationDate: [null, [Validators.required, dateNotInPastValidator]],
    });
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

    this.deptService.create(this.departmentForm.value).subscribe({
      next: (r) => {
        this.toastr.success(r.message ?? 'Successfully created department.');
        this.departmentForm.reset();
      },
      error: (e) => {
        handleFormErrors(this.departmentForm, e, this.toastr);
      },
    });
  }

  ngOnDestroy(): void {}
}
