import { AsyncPipe, DatePipe, NgClass } from '@angular/common';
import { Component, OnInit, TemplateRef } from '@angular/core';
import { Rating, REVIEW_RATING } from '@constants/constants';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import { faXmark } from '@fortawesome/free-solid-svg-icons';
import { EmployeeReviewDto } from '@models/review.model';
import { AuthenticationService } from '@services/authentication.service';
import { ReviewService } from '@services/review.service';
import { handleApiErrors } from '@utils/error-handler';
import { BsModalRef, BsModalService } from 'ngx-bootstrap/modal';
import { ToastrService } from 'ngx-toastr';
import { catchError, Observable, of } from 'rxjs';

@Component({
  selector: 'app-view-reviews',
  imports: [AsyncPipe, DatePipe, FontAwesomeModule, NgClass],
  providers: [BsModalService],
  templateUrl: './view-reviews.component.html',
  styleUrl: './view-reviews.component.scss',
  standalone: true,
})
export class ViewReviewsComponent implements OnInit {
  reviews$: Observable<EmployeeReviewDto[]>;
  selectedReview: EmployeeReviewDto;
  modalRef?: BsModalRef;
  faXmark = faXmark;
  userId: number;
  constructor(
    private api: ReviewService,
    private toastr: ToastrService,
    private auth: AuthenticationService,
    private modalService: BsModalService
  ) {}

  ngOnInit(): void {
    const id = this.auth.getUserId();
    if (id) {
      this.userId = id;
      this.reviews$ = this.api.getAllReviews(id).pipe(
        catchError((e) => {
          handleApiErrors(e, this.toastr);
          return of([]);
        })
      );
    }
  }

  openModal(template: TemplateRef<void>, review: EmployeeReviewDto) {
    this.selectedReview = review;
    this.modalRef = this.modalService.show(template, {
      class: 'modal-md',
    });

    this.modalRef.onHidden?.subscribe(() => {
      this.api.markReviewAsRead(this.selectedReview.id).subscribe(() => {
        this.reviews$ = this.api.getAllReviews(this.userId);
      });
    });
  }

  getRatingInfo(label: string) {
    return REVIEW_RATING.find(
      (r) => r.label.toLowerCase() === label.trim().toLowerCase()
    );
  }

  getRatingClass(label: string): string {
    const rating = this.getRatingInfo(label); // from your previous helper
    switch (rating?.value) {
      case Rating.BELOW:
        return 'text-danger';
      case Rating.MEETS:
        return 'text-info';
      case Rating.EXCEEDS:
        return 'text-success';
      default:
        return '';
    }
  }
}
