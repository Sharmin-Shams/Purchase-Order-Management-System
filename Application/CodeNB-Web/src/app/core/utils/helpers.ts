import { AbstractControl, ValidatorFn } from '@angular/forms';
import { UserRole } from '@constants/constants';

export const isAllowRole = (allowedRoles: UserRole[], roleName: string) => {
  roleName = roleName.toLowerCase().trim();
  return allowedRoles.some((r) => r.toLowerCase() === roleName);
};

export const padWithZeros = (num: number, length: number = 8): string => {
  return num.toString().padStart(length, '0');
};

export const isSupervisor = (roleName: string) => {
  roleName = roleName.toLowerCase().trim();

  const allowedRoles = [
    UserRole.CEO,
    UserRole.HRSupervisor,
    UserRole.RegularSupervisor,
  ];

  return allowedRoles.some((r) => r.toLowerCase() === roleName);
};

export const isSupervisorExceptCEO = (roleName: string) => {
  roleName = roleName.toLowerCase().trim();

  const allowedRoles = [UserRole.HRSupervisor, UserRole.RegularSupervisor];

  return allowedRoles.some((r) => r.toLowerCase() === roleName);
};

export const stripTimezone = (date: string | null) => {
  return date?.split('T')[0] ?? null;
};

export const getLocalDate = (date: null | Date = null) => {
  const today = date ?? new Date();
  return `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(
    2,
    '0'
  )}-${String(today.getDate()).padStart(2, '0')}`;
};

export const setField = (
  control: AbstractControl | null | undefined,
  value: string,
  validators: any[] | ValidatorFn | ValidatorFn[] = []
) => {
  control?.setValue(value);
  control?.addValidators(validators);
  control?.updateValueAndValidity();
};

export const clearField = (control: AbstractControl | null | undefined) => {
  control?.setErrors(null);
  control?.clearValidators();
  control?.updateValueAndValidity();
};

export const getQuarterDateRange = (year: number, quarter: number) => {
  const today = new Date();
  const currentYear = today.getFullYear();
  const currentMonth = today.getMonth(); // 0-based

  // Determine current quarter (1-4)
  const currentQuarter = Math.floor(currentMonth / 3) + 1;

  let minDate: Date;
  let maxDate: Date;

  switch (quarter) {
    case 1:
      minDate = new Date(year, 0, 1); // Jan 1
      maxDate = new Date(year, 2, 31); // Mar 31
      break;
    case 2:
      minDate = new Date(year, 3, 1); // Apr 1
      maxDate = new Date(year, 5, 30); // Jun 30
      break;
    case 3:
      minDate = new Date(year, 6, 1); // Jul 1
      maxDate = new Date(year, 8, 30); // Sep 30
      break;
    case 4:
      minDate = new Date(year, 9, 1); // Oct 1
      maxDate = new Date(year, 11, 31); // Dec 31
      break;
    default:
      throw new Error('Invalid quarter. Must be 1, 2, 3, or 4.');
  }

  if (year === currentYear && quarter === currentQuarter) {
    maxDate = today;
  }

  return { minDate, maxDate };
};

export const isCurrentQuarterAndYear = (year: number, quarter: number) => {
  const today = new Date();
  const currentQuarter = Math.floor(today.getMonth() / 3) + 1; // 0-based
  return year === today.getFullYear() && quarter === currentQuarter;
};
