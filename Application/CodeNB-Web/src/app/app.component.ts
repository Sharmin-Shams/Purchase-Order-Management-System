import { Component, OnDestroy, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { AuthenticationService } from '@services/authentication.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  template: '<router-outlet></router-outlet>',
  styles: '',
  standalone: true,
})
export class AppComponent implements OnInit, OnDestroy {
  constructor(private authService: AuthenticationService) {}

  ngOnInit(): void {
    this.authService.autoAuthUser();
  }

  ngOnDestroy(): void {}
}
