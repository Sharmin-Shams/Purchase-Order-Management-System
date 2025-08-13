import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

// import { PO_ROUTE_GRANTS, UserRole } from '@constants/constants';
import { UserRole } from '@constants/constants';

import { AuthenticationService } from '@services/authentication.service';
import { isSupervisor } from '@utils/helpers';

@Component({
  selector: 'app-view',
  imports: [RouterModule, FormsModule, CommonModule],
  templateUrl: './view.component.html',
  styleUrl: './view.component.scss',
})
export class ViewComponent implements OnInit {
canViewSupervisorLink = false;
  constructor(private authService: AuthenticationService) {}

  ngOnInit(): void {
    const role = this.authService.getRole() ?? "";
    this.canViewSupervisorLink = isSupervisor(role);
  }
}
