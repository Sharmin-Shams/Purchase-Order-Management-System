import { Component, OnInit, TemplateRef } from '@angular/core';
import { AuthenticationService } from '@services/authentication.service';
import { ReviewService } from '@services/review.service';
import { handleApiErrors, handleFormErrors } from '@utils/error-handler';
import { ToastrService } from 'ngx-toastr';
import { catchError, Observable, of } from 'rxjs';
import {
  AccordionComponent,
  AccordionPanelComponent,
} from 'ngx-bootstrap/accordion';
import { AsyncPipe, NgClass, NgFor, NgIf } from '@angular/common';
import { BsModalRef, BsModalService, ModalModule } from 'ngx-bootstrap/modal';
import { faXmark } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { Rating, REVIEW_RATING } from '@constants/constants';
import { EmployeesForReviewResultDto } from '@models/review.model';
import { EmployeeDto } from '@models/employee.model';
import {
  getLocalDate,
  getQuarterDateRange,
  isCurrentQuarterAndYear,
  setField,
} from '@utils/helpers';
import { dateInRangeValidator } from '@validators/form.validators';
@Component({
  selector: 'app-view-pending-reviews',
  imports: [
    AccordionComponent,
    AccordionPanelComponent,
    NgFor,
    AsyncPipe,
    ReactiveFormsModule,
    ModalModule,
    FontAwesomeModule,
    NgClass,
    NgIf,
  ],
  providers: [BsModalService],
  templateUrl: './view-pending-reviews.component.html',
  styleUrl: './view-pending-reviews.component.scss',
  standalone: true,
})
export class ViewPendingReviewsComponent implements OnInit {
  faXmark = faXmark;
  customClass = 'panelCustomClass';
  modalRef?: BsModalRef;
  ratingEnum = Rating;
  REVIEW_RATING = REVIEW_RATING;

  pendingEmployees$: Observable<EmployeesForReviewResultDto[]>;
  employeeToReview: EmployeeDto;
  minDate: string;
  maxDate: string;
  userId: number | null;

  reviewForm: FormGroup;

  constructor(
    private api: ReviewService,
    private toastr: ToastrService,
    private auth: AuthenticationService,
    private modalService: BsModalService,
    private fb: FormBuilder
  ) {}

  ngOnInit(): void {
    this.userId = this.auth.getUserId();
    if (this.userId) {
      this.pendingEmployees$ = this.api
        .getAllPendingEmployeesToReview(this.userId)
        .pipe(
          catchError((e) => {
            handleApiErrors(e, this.toastr);
            return of([]);
          })
        );
    }
  }

  openModal(
    template: TemplateRef<void>,
    data: EmployeesForReviewResultDto,
    id: number
  ) {
    const e = data.employees.find((e) => e.id === id);
    if (e) {
      this.initForm();
      this.initValues(data, e);
      this.modalRef = this.modalService.show(template, {
        class: 'modal-lg',
        backdrop: 'static',
      });
    }
  }

  onSubmit() {
    if (this.reviewForm.invalid) {
      this.reviewForm.markAllAsTouched();
      return;
    }

    this.api.create(this.reviewForm.value).subscribe({
      next: (r) => {
        this.toastr.success(r.message ?? 'Successfully created review.');
        this.pendingEmployees$ = this.api.getAllPendingEmployeesToReview(
          this.userId!
        );
        this.modalRef?.hide();
      },
      error: (e) => {
        handleFormErrors(this.form, e, this.toastr);
      },
    });
  }

  initForm() {
    this.reviewForm = this.fb.group({
      employeeID: [null],
      supervisorID: [null],
      year: [null],
      quarter: [null],
      isRead: [null],

      comment: ['', Validators.required],
      reviewDate: ['', Validators.required],
      ratingID: [null, Validators.required],
    });
  }

  initValues(data: EmployeesForReviewResultDto, e: EmployeeDto) {
    this.employeeToReview = e;
    this.reviewForm.patchValue({
      employeeID: e.id,
      supervisorID: this.userId,
      year: data.year,
      quarter: data.quarter,
    });

    const { minDate, maxDate } = getQuarterDateRange(data.year, data.quarter);
    this.minDate = getLocalDate(minDate);
    this.maxDate = getLocalDate(maxDate);

    setField(
      this.reviewDate,
      isCurrentQuarterAndYear(data.year, data.quarter)
        ? this.maxDate
        : this.minDate,
      [dateInRangeValidator(this.minDate, this.maxDate)]
    );
  }

  getControlError(controlName: string, displayName: string, to?: string) {
    const control = this.reviewForm.get(controlName);
    if (control && control.touched && control.invalid) {
      const errors = control.errors;
      if (errors) {
        return Object.keys(errors).map((key) => {
          if (key === 'required') return `${displayName} is required.`;
          if (key === 'dateBeforeMin' || key === 'dateAfterMax')
            return `${displayName} must be within the selected quarter and year.`;
          if (key === 'invalidDate') return `${displayName} is invalid.`;
          if (key === 'fieldError') return errors['fieldError'];
        });
      }
    }
    return [];
  }

  get form() {
    return this.reviewForm;
  }

  get comment() {
    return this.reviewForm.get('comment');
  }
  get reviewDate() {
    return this.reviewForm.get('reviewDate');
  }

  get rating() {
    return this.reviewForm.get('ratingID');
  }
}
