export class EmployeeAssignment {
  employeeName?: string;
  departmentName?: string;
  supervisorName?: string;
}

export class Employee {
  id: number;
  password: string;
  firstName: string;
  lastName: string;
  middleInitial: string | null;
  streetAddress: string;
  city: string;
  postalCode: string;
  doB: string;
  sin: string;
  seniorityDate: string;
  jobStartDate: string;
  workPhone: string;
  cellPhone: string;
  email: string;
  isSupervisor: boolean | null;
  supervisorID: number;
  departmentID: number;
  jobID: number;
  officeLocation: string;
  status: string;
  retirementDate: string | null;
  terminationDate: string | null;
  rowVersion: string;
}

export class EmployeeDto {
  id: number;
  firstName: string;
  middleInitial: string | null;
  lastName: string;
}

export interface EmployeeSearchDto {
  departmentID: number | null;
  employeeID: string | null;
  lastName: string | null;
}

export interface EmployeeDetailsResultDto {
  id: number;
  firstName: string;
  middleInitial: string | null;
  lastName: string;
  mailingAddress: string;
  workPhone: string;
  cellPhone: string;
  email: string;
}

export type EmployeeDetailsResult = Omit<EmployeeDetailsResultDto, 'id'> & {
  id: string;
};

export interface EmployeeDetailsResultDto {
  id: number;
  firstName: string;
  middleInitial: string | null;
  lastName: string;
  mailingAddress: string;
  workPhone: string;
  cellPhone: string;
  email: string;
}

export interface PersonalInfoDto {
  id: number;
  password: string;
  firstName: string;
  middleInitial: string | null;
  lastName: string;
  streetAddress: string;
  city: string;
  postalCode: string;
  rowVersion: string;
}