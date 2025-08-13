import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { BaseApiService } from './base-api.service';
import {
  Employee,
  EmployeeAssignment,
  EmployeeDetailsResultDto,
  EmployeeDto,
  EmployeeSearchDto,
  PersonalInfoDto,
} from '@models/employee.model';
import { ApiMessageResponse } from '@models/api/api-response';
import { buildHttpParams, sanitizeRequestBody } from '@utils/http-utils';

@Injectable({
  providedIn: 'root',
})
export class EmployeeService extends BaseApiService {
  constructor(http: HttpClient) {
    super(http);
  }

  getEmployeeAssignment(employeeId: number) {
    return this.http.get<EmployeeAssignment>(
      `${this.baseUrl}/employees/assignment/${employeeId}`
    );
  }

  getAllSupervisors() {
    return this.http.get<EmployeeDto[]>(
      `${this.baseUrl}/employees/supervisors`
    );
  }

  create(employee: Employee) {
    return this.http.post<ApiMessageResponse>(
      `${this.baseUrl}/employees`,
      sanitizeRequestBody(employee)
    );
  }

  searchEmployee(search: EmployeeSearchDto) {
    const params = buildHttpParams(search);

    return this.http.get<EmployeeDetailsResultDto[]>(
      `${this.baseUrl}/employees/details/search`,
      { params: params }
    );
  }

  getEmployee(id: number) {
    return this.http.get<Employee>(`${this.baseUrl}/employees/${id}`);
  }

  getPersonalInfo(id: number) {
    return this.http.get<PersonalInfoDto>(
      `${this.baseUrl}/employees/info/${id}`
    );
  }

  updatePersonalInfo(info: PersonalInfoDto) {
    return this.http.put<ApiMessageResponse>(
      `${this.baseUrl}/employees/info`,
      sanitizeRequestBody(info)
    );
  }

  updateEmployee(employee: Employee) {
    return this.http.put<ApiMessageResponse>(
      `${this.baseUrl}/employees`,
      sanitizeRequestBody(employee)
    );
  }
}
