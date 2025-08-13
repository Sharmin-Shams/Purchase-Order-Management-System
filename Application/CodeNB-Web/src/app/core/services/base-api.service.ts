import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { environment } from 'environments/environment';

@Injectable({
  providedIn: 'root',
})
export abstract class BaseApiService {
  protected readonly baseUrl = environment.apiUrl;
  constructor(protected readonly http: HttpClient) {}
}
