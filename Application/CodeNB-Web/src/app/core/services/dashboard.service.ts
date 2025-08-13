import { Injectable } from '@angular/core';
import { API_URL, SharedService } from './shared.service';
import { HttpClient } from '@angular/common/http';
import { catchError, Observable } from 'rxjs';
import { DashboardDto } from '@models/dashboard-dto';

@Injectable({
  providedIn: 'root'
})
export class DashboardService extends SharedService{

  constructor(private http: HttpClient) {
    super()
   }

   getEmployeeDashboard() : Observable<DashboardDto>{
    return this.http
    .get<DashboardDto>(`${API_URL}/Dashboard`)
       .pipe(catchError(super.handleError));
   }
getSupervisorDashboard(): Observable<DashboardDto> {
    return this.http.get<DashboardDto>(`${API_URL}/Dashboard/dashboard-supervisor`)
    .pipe(catchError(super.handleError));
  }
   
}
