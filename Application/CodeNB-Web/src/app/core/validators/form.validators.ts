import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';
import { PASSWORD_REGEX } from '@constants/constants';

export const dateNotInPastValidator: ValidatorFn = (
  control: AbstractControl
): ValidationErrors | null => {
  const value = control.value;
  if (!value) return null;

  const [year, month, day] = value.split('-').map(Number);
  const inputUtc = new Date(Date.UTC(year, month - 1, day));
  if (isNaN(inputUtc.getTime())) return { invalidDate: true };

  const now = new Date();
  const todayUtc = new Date(
    Date.UTC(now.getFullYear(), now.getMonth(), now.getDate())
  );
  return inputUtc < todayUtc ? { dateInPast: true } : null;
};

export const invocationDateValidator = (
  getOriginalDate: () => string | null
): ValidatorFn => {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = control.value;
    const original = getOriginalDate();

    if ((!value || !original) || (value === original)) return null;

    const [year, month, day] = value.split('-').map(Number);
    const inputUtc = new Date(Date.UTC(year, month - 1, day));
    if (isNaN(inputUtc.getTime())) return { invalidDate: true };

    const now = new Date();
    const todayUtc = new Date(
      Date.UTC(now.getFullYear(), now.getMonth(), now.getDate())
    );

    return inputUtc < todayUtc ? { dateInPast: true } : null;
  };
};

export function minimumAgeValidator(minAge: number): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = control.value;
    if (!value) return null;

    const [year, month, day] = value.split('-').map(Number);
    const dobUtc = new Date(Date.UTC(year, month - 1, day));
    if (isNaN(dobUtc.getTime())) return { invalidDate: true };

    const today = new Date();
    const todayUtc = new Date(
      Date.UTC(today.getFullYear(), today.getMonth(), today.getDate())
    );

    let age = todayUtc.getUTCFullYear() - dobUtc.getUTCFullYear();

    const hasBirthdayPassedThisYear =
      todayUtc.getUTCMonth() > dobUtc.getUTCMonth() ||
      (todayUtc.getUTCMonth() === dobUtc.getUTCMonth() &&
        todayUtc.getUTCDate() >= dobUtc.getUTCDate());

    if (!hasBirthdayPassedThisYear) {
      age--;
    }

    return age < minAge
      ? { age: { requiredAge: minAge, actualAge: age } }
      : null;
  };
}

export function requiredMinMaxLengthTrimmed(
  min?: number | null,
  max?: number | null
): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = control.value || '';
    const trimmed = value.trim();
    const length = trimmed.length;

    if (length === 0) {
      return { required: true };
    }

    if (min && length < min) {
      return { minlength: { requiredLength: min, actualLength: length } };
    }

    if (max && length > max) {
      return { maxlength: { requiredLength: max, actualLength: length } };
    }

    return null;
  };
}

export function dateAfterValidator(
  earlierControlName: string,
  laterControlName: string,
  controlNameToSetError: string
): ValidatorFn {
  return (group: AbstractControl): ValidationErrors | null => {
    const earlier = group.get(earlierControlName)?.value;
    const later = group.get(laterControlName)?.value;

    if (!earlier || !later) return null;

    const [ey, em, ed] = earlier.split('-').map(Number);
    const [ly, lm, ld] = later.split('-').map(Number);

    const earlierDate = new Date(Date.UTC(ey, em - 1, ed));
    const laterDate = new Date(Date.UTC(ly, lm - 1, ld));

    if (isNaN(earlierDate.getTime()) || isNaN(laterDate.getTime()))
      return { invalidDate: true };

    if (laterDate < earlierDate)
      group.get(controlNameToSetError)?.setErrors({ invalidDateOrder: true });
    else group.get(controlNameToSetError)?.setErrors(null);
    return null;
  };
}

export function passwordPatternIfChanged(original: string): ValidatorFn {
  const regex = new RegExp(PASSWORD_REGEX);
  return (control: AbstractControl): ValidationErrors | null => {
    const newPassword = control.value;
    if (!newPassword || newPassword === original) {
      return null; // Skip validation if not changed or empty
    }

    return regex.test(newPassword) ? null : { invalidPassword: true };
  };
}

export function dateInRangeValidator(
  minDateStr: string,
  maxDateStr: string
): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = control.value;
    if (!value) return null;

    const [year, month, day] = value.split('-').map(Number);
    const inputUtc = new Date(Date.UTC(year, month - 1, day));
    if (isNaN(inputUtc.getTime())) 
      return { invalidDate: true };

    const [minY, minM, minD] = minDateStr.split('-').map(Number);
    const minUtc = new Date(Date.UTC(minY, minM - 1, minD));

    const [maxY, maxM, maxD] = maxDateStr.split('-').map(Number);
    const maxUtc = new Date(Date.UTC(maxY, maxM - 1, maxD));

    if (inputUtc < minUtc) 
      return { dateBeforeMin: true };
    if (inputUtc > maxUtc) 
      return { dateAfterMax: true };

    return null;
  };
}
