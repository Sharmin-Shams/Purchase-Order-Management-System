import { HttpErrorResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from 'environments/environment';
import { Observable, throwError } from 'rxjs';

export const API_URL =environment.apiUrl;
@Injectable({
  providedIn: 'root'
})
export abstract class SharedService {

  constructor() { }

   /**
   * Http error handler
   * @param err http error from the http request
   * @returns The exception
   */
   protected handleError(err: HttpErrorResponse): Observable<never> {
    //Network based errors
    if (err.error instanceof ProgressEvent) {
      console.log('Progress event error detected');

      return throwError(() => new Error('Error connection to REST Server'));
    }

    // Server side errors
    return throwError(() => err);
  }
}
