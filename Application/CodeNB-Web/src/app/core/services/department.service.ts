import { Injectable } from '@angular/core';
import { BaseApiService } from './base-api.service';
import { HttpClient } from '@angular/common/http';
import { Department, DepartmentDto } from '@models/department.model';
import { ApiMessageResponse } from '@models/api/api-response';
import { sanitizeRequestBody } from '@utils/http-utils';

@Injectable({
  providedIn: 'root',
})
export class DepartmentService extends BaseApiService {
  constructor(http: HttpClient) {
    super(http);
  }

  create(department: Department) {
    return this.http.post<ApiMessageResponse>(
      `${this.baseUrl}/departments`,
      sanitizeRequestBody(department)
    );
  }

  getAll() {
    return this.http.get<DepartmentDto[]>(`${this.baseUrl}/departments`);
  }

  getAllWithDetails() {
    return this.http.get<Department[]>(`${this.baseUrl}/departments/details`);
  }

  update(department: Department) {
    return this.http.put<ApiMessageResponse>(
      `${this.baseUrl}/departments`,
      sanitizeRequestBody(department)
    );
  }

  delete(department: Department) {
    return this.http.delete<ApiMessageResponse>(`${this.baseUrl}/departments`, {
      body: sanitizeRequestBody(department),
      observe: 'body',
    });
  }
}
