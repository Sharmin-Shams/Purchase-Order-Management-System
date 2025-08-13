import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { BaseApiService } from './base-api.service';
import {
  EmployeeReviewDto,
  EmployeesForReviewResultDto,
  Review,
} from '@models/review.model';
import { ApiMessageResponse } from '@models/api/api-response';
import { sanitizeRequestBody } from '@utils/http-utils';

@Injectable({
  providedIn: 'root',
})
export class ReviewService extends BaseApiService {
  constructor(http: HttpClient) {
    super(http);
  }

  getAllPendingEmployeesToReview(id: number) {
    return this.http.get<EmployeesForReviewResultDto[]>(
      `${this.baseUrl}/reviews/pending?id=${id}`
    );
  }

  getAllReviews(id: number) {
    return this.http.get<EmployeeReviewDto[]>(`${this.baseUrl}/reviews/${id}`);
  }

  create(review: Review) {
    return this.http.post<ApiMessageResponse>(
      `${this.baseUrl}/reviews`,
      sanitizeRequestBody(review)
    );
  }

  markReviewAsRead(id: number) {
    return this.http.put(`${this.baseUrl}/reviews/read/${id}`, null);
  }
}
