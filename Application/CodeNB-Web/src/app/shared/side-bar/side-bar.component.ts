import { Component, OnDestroy, OnInit } from '@angular/core';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import { AuthenticationService } from '@services/authentication.service';
import { Subject, takeUntil } from 'rxjs';
import {
  faFileInvoiceDollar,
  faRightToBracket,
  faUsersGear,
  faRightFromBracket,
  faUser,
  faTable,
} from '@fortawesome/free-solid-svg-icons';
import { UserRole } from '@constants/constants';
import { isAllowRole } from '@utils/helpers';

@Component({
  selector: 'app-side-bar',
  imports: [RouterLink, RouterLinkActive, FontAwesomeModule],
  templateUrl: './side-bar.component.html',
  styleUrl: './side-bar.component.scss',
  standalone: true,
})
export class SideBarComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();
  isLoggedIn: boolean = false;
  isShowPo: boolean = true;
  isShowHr: boolean = false;

  faTable = faTable;
  faFileInvoiceDollar = faFileInvoiceDollar;
  faUsersGear = faUsersGear;
  faRightToBracket = faRightToBracket;
  faRightFromBracket = faRightFromBracket;
  faUser = faUser;
  
  constructor(
    private authService: AuthenticationService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.isLoggedIn = this.authService.getIsAuthenticated() ?? false;
    const role = this.authService.getRole() ?? null;
    if (role) {
      this.isShowHr = isAllowRole(
        [UserRole.CEO, UserRole.HRSupervisor, UserRole.HREmployee],
        role
      );
    }

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
