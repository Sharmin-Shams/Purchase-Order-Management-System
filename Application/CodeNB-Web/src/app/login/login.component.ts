import { NgClass, NgIf } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { API_STATUS } from '@constants/constants';
import { Login } from '@models/auth/login';
import { AuthenticationService } from '@services/authentication.service';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-login',
  imports: [ReactiveFormsModule, NgClass, NgIf, RouterModule],
  providers: [AuthenticationService],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss',
  standalone: true,
})
export class LoginComponent implements OnInit {
  loginForm: FormGroup;

  constructor(
    private fb: FormBuilder,
    private api: AuthenticationService,
    private router: Router,
    private toastr: ToastrService
  ) {}

  get username() {
    return this.loginForm.get('username')!;
  }

  get password() {
    return this.loginForm.get('password')!;
  }

  ngOnInit(): void {
    this.loginForm = this.fb.group({
      username: [
        '',
        [Validators.required, Validators.minLength(8), Validators.maxLength(8)],
      ],
      password: ['', Validators.required],
    });
  }

  onSubmit() {
    if (this.loginForm.invalid) {
      this.loginForm.markAllAsTouched();
      return;
    }

    const loginData: Login = this.loginForm.value;
    this.api.login(loginData).subscribe({
      next: (_) => this.toastr.success('Successfully logged in'),
      error: (e) => {
        this.toastr.error(
          e.error.message ?? API_STATUS[e.status] ?? API_STATUS[500]
        );
      },
      complete: () => this.router.navigate(['/']),
    });
  }
}
