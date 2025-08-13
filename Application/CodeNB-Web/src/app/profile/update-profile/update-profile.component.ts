import { NgClass, NgFor, NgIf } from '@angular/common';
import { Component, OnDestroy, OnInit } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { POSTAL_REGEX } from '@constants/constants';
import { PersonalInfoDto } from '@models/employee.model';
import { AuthenticationService } from '@services/authentication.service';
import { EmployeeService } from '@services/employee.service';
import { handleApiErrors, handleFormErrors } from '@utils/error-handler';
import { padWithZeros } from '@utils/helpers';
import {
  passwordPatternIfChanged,
  requiredMinMaxLengthTrimmed,
} from '@validators/form.validators';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-update-profile',
  imports: [ReactiveFormsModule, NgClass, NgIf, NgFor],
  templateUrl: './update-profile.component.html',
  styleUrl: './update-profile.component.scss',
})
export class UpdateProfileComponent implements OnInit, OnDestroy {
  info: PersonalInfoDto;
  employeeForm: FormGroup;

  constructor(
    private api: EmployeeService,
    private auth: AuthenticationService,
    private toastr: ToastrService,
    private fb: FormBuilder
  ) {}

  ngOnDestroy(): void {}

  ngOnInit(): void {
    this.employeeForm = this.fb.group({
      id: [{ value: null }],
      rowVersion: [''],
      password: ['', Validators.required],
      firstName: [{ value: '' }],
      lastName: [{ value: '' }],
      middleInitial: [{ value: null }],
      streetAddress: ['', requiredMinMaxLengthTrimmed()],
      city: ['', requiredMinMaxLengthTrimmed()],
      postalCode: ['', [Validators.required, Validators.pattern(POSTAL_REGEX)]],
    });

    this.loadPersonalInfo();
  }

  onSubmit() {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const data: PersonalInfoDto = {
      ...this.employeeForm.getRawValue(),
      password: this.getPassword(),
    };

    this.api.updatePersonalInfo(data).subscribe({
      next: (r) => {
        this.toastr.success(
          r.message ?? 'Successfully updated user information.'
        );

        this.loadPersonalInfo();
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
          if (key === 'fieldError') return errors['fieldError'];
        });
      }
    }
    return [];
  }

  loadPersonalInfo(): void {
    this.employeeForm.reset();
    const id = this.auth.getUserId()!;
    this.api.getPersonalInfo(id).subscribe({
      next: (r) => {
        this.info = r;
        this.initValues(r);
      },
      error: (e) => handleApiErrors(e, this.toastr),
    });
  }

  private getPassword() {
    if (
      this.password?.value.substring(0, 32) ===
      this.info.password?.substring(0, 32)
    )
      return this.info.password;

    return this.password?.value;
  }

  private initValues(info: PersonalInfoDto) {
    this.employeeForm.patchValue({
      id: padWithZeros(info.id),
      rowVersion: info.rowVersion,
      password: info.password.substring(0, 32),
      firstName: info.firstName,
      lastName: info.lastName,
      middleInitial: info.middleInitial,
      streetAddress: info.streetAddress,
      city: info.city,
      postalCode: info.postalCode,
    });

    this.password?.addValidators(
      passwordPatternIfChanged(info.password.substring(0, 32))
    );
    this.password?.updateValueAndValidity();
  }

  get form() {
    return this.employeeForm;
  }

  get password() {
    return this.form.get('password');
  }
}
