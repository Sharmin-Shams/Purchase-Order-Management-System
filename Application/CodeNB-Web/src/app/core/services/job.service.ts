import { Injectable } from '@angular/core';
import { BaseApiService } from './base-api.service';
import { HttpClient } from '@angular/common/http';
import { Job } from '@models/job.model';

@Injectable({
  providedIn: 'root',
})
export class JobService extends BaseApiService {
  constructor(http: HttpClient) {
    super(http);
  }

  getAll() {
    return this.http.get<Job[]>(`${this.baseUrl}/jobs`);
  }
}
