import { Component, OnDestroy, OnInit } from '@angular/core';
import { Router, RouterModule } from '@angular/router';
import { AuthenticationService } from '@services/authentication.service';
import { Subject, takeUntil } from 'rxjs';

@Component({
  selector: 'app-topbar',
  imports: [RouterModule],
  templateUrl: './topbar.component.html',
  styleUrl: './topbar.component.scss',
  standalone: true,
})
export class TopbarComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();
  isLoggedIn: boolean = false;

  constructor(
    private authService: AuthenticationService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.isLoggedIn = this.authService.getIsAuthenticated() ?? false;
    this.authService
      .getAuthStatusListener()
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (auth) => {
          this.isLoggedIn = auth?.authenticated ?? false;
        },
      });
  }

  logout() {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
