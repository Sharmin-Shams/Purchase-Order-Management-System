export const API_STATUS: { [key: number]: string } = {
  400: 'An error occurred. Please check your input.',
  401: 'You are not authorized. Please log in.',
  403: 'Access denied. You do not have permission.',
  404: 'Resource not found.',
  500: 'An error occurred. Please try again later.',
  0: 'An unknown error occurred. Please try again later.',
};

export enum UserRole {
  CEO = 'CEO',
  HRSupervisor = 'HRSupervisor',
  HREmployee = 'HREmployee',
  RegularSupervisor = 'RegularSupervisor',
  RegularEmployee = 'RegularEmployee',
}

export enum EmployeeStatus {
  ACTIVE = 'ACTIVE',
  RETIRED = 'RETIRED',
  TERMINATED = 'TERMINATED',
}

export const EMPLOYEE_STATUS: {
  value: EmployeeStatus;
  label: string;
}[] = [
  { value: EmployeeStatus.ACTIVE, label: 'Active' },
  { value: EmployeeStatus.RETIRED, label: 'Retired' },
  { value: EmployeeStatus.TERMINATED, label: 'Terminated' },
];

export enum Rating {
  BELOW = 1,
  MEETS = 2,
  EXCEEDS = 3,
}

export const REVIEW_RATING: {
  value: Rating;
  label: string;
}[] = [
  { value: Rating.BELOW, label: 'Below Expectations' },
  { value: Rating.MEETS, label: 'Meets Expectations' },
  { value: Rating.EXCEEDS, label: 'Exceeds Expectations' },
];

export const PHONE_REGEX = '^\\(?\\d{3}\\)?[-.\\s]?\\d{3}[-.\\s]?\\d{4}$';
export const SIN_REGEX = '^\\d{3}[- ]?\\d{3}[- ]?\\d{3}$';
export const POSTAL_REGEX = '^[A-Za-z]\\d[A-Za-z] ?\\d[A-Za-z]\\d$';
export const PASSWORD_REGEX = '^(?=.*[A-Z])(?=.*\\d)(?=.*[\\W_]).{6,}$';
export const MIN_AGE = 16;
