import { Component, OnInit } from '@angular/core';
import { RouterModule } from '@angular/router';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import {
  faArrowRight,
  faBuilding,
  faUsers,
  faUsersGear,
} from '@fortawesome/free-solid-svg-icons';
import { AuthenticationService } from '@services/authentication.service';

@Component({
  selector: 'app-view',
  imports: [RouterModule, FontAwesomeModule],
  templateUrl: './view.component.html',
  styleUrl: './view.component.scss',
  standalone: true,
})
export class ViewComponent implements OnInit {
  icon = faUsersGear;
  deptIcon = faBuilding;
  empIcon = faUsers;
  arrowIcon = faArrowRight;

  constructor(private api: AuthenticationService) {}

  ngOnInit(): void {
    let user = this.api.getUser();
  }
}
