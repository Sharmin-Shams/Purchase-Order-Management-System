import { FormGroup } from '@angular/forms';
import { API_STATUS } from '@constants/constants';
import { ValidationError } from '@models/validation-error';
import { ToastrService } from 'ngx-toastr';

export function handleFormErrors(
  form: FormGroup,
  e: any,
  toastr: ToastrService
): void {
  if (e.error) {
    if (e.error.errors && e.error.errors.length) {
      e.error.errors.forEach((err: ValidationError) => {
        const fieldName = err.field?.toLowerCase();
        const formCtrlName = Object.keys(form.controls).find(
          (k) => k.toLowerCase() === fieldName
        );
        if (formCtrlName) {
          form.get(formCtrlName)?.setErrors({
            fieldError: err.description,
          });

          form.get(formCtrlName)?.markAsTouched();
        }
      });
    } else {
      toastr.error(e.error.message ?? API_STATUS[e.status] ?? API_STATUS[500]);
    }
  } else {
    toastr.error(API_STATUS[e.status] ?? API_STATUS[500]);
  }
}

export function handleApiErrors(e: any, toastr: ToastrService): void {
  toastr.error(e.error?.message ?? API_STATUS[e.status] ?? API_STATUS[500]);
}
