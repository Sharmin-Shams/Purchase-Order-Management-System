import { EmployeeDto } from './employee.model';

export interface EmployeesForReviewResultDto {
  year: number;
  quarter: number;
  employees: EmployeeDto[];
}

export interface Review {
  employeeID: number;
  supervisorID: number;
  ratingID: number;
  year: number;
  quarter: number;
  comment: string;
  reviewDate: string;
  isRead: boolean | null;
}

export interface EmployeeReviewDto {
  id: number;
  year: number;
  quarter: number;
  reviewDate: string;
  supervisorName: string;
  comment: string;
  rating: string;
  isRead: boolean;
}
