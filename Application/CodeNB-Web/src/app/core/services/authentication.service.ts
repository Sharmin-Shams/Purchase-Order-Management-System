import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { BaseApiService } from './base-api.service';
import { Login } from '@models/auth/login';
import { Observable, Subject, tap } from 'rxjs';
import { AuthData, AuthUser, User } from '@models/auth/user';

@Injectable({
  providedIn: 'root',
})
export class AuthenticationService extends BaseApiService {
  private tokenTimer: string | number | NodeJS.Timeout | undefined;
  private user: AuthUser | null;
  private token: string | null;
  private authStatusListener = new Subject<AuthUser | null>();

  constructor(http: HttpClient) {
    super(http);
  }

  getAuthStatusListener() {
    return this.authStatusListener.asObservable();
  }

  getUserId() {
    return this.user?.id ?? null;
  }

  getRole() {
    return this.user?.role;
  }

  getToken() {
    return this.token;
  }

  getIsAuthenticated() {
    return this.user?.authenticated ?? false;
  }

  getUser() {
    return this.user;
  }

  login(login: Login): Observable<User> {
    return this.http.post<User>(`${this.baseUrl}/auth/login`, login).pipe(
      tap((response) => {
        this.token = response.token;

        if (!!this.token) {
          const expiry = response.expiresIn;

          this.setAuthTimer(expiry);

          const { token, expiresIn, ...rest } = response;
          this.user = { ...rest, authenticated: true };
          this.authStatusListener.next(this.user);
          this.saveAuthData(response);
        }
      })
    );
  }

  logout() {
    this.user = null;
    this.token = null;
    this.authStatusListener.next(null);

    clearTimeout(this.tokenTimer);
    this.clearAuthData();
  }

  autoAuthUser() {
    const authData = this.getAuthData();
    if (!authData) return;

    const now = new Date();
    const expiryDate = new Date(authData.expiresAt);

    const expiresIn = expiryDate.getTime() - now.getTime();

    if (expiresIn > 0) {
      this.token = authData!.token;

      const { token, expiresAt, ...rest } = authData;
      this.user = { ...rest };

      this.authStatusListener.next(this.user);
      this.setAuthTimer(expiresIn / 1000);
    }
  }

  private getAuthData() {
    const user = localStorage.getItem('user');

    if (!user) return;

    const data: AuthData = JSON.parse(user) ?? null;
    if (!data) return;

    return data;
  }

  private saveAuthData(user: User) {
    const { expiresIn, ...rest } = user;
    const expiresAt = new Date(Date.now() + expiresIn * 1000);
    localStorage.setItem(
      'user',
      JSON.stringify({
        ...rest,
        expiresAt: expiresAt.toISOString(),
        authenticated: true,
      })
    );
  }

  private clearAuthData() {
    localStorage.removeItem('user');
  }

  private setAuthTimer(expiresIn: number) {
    this.tokenTimer = setTimeout(() => {
      this.logout();
    }, expiresIn * 1000);
  }
}
