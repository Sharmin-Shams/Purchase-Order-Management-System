import { Component, OnInit, TemplateRef } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  FormsModule,
  NgModel,
  ReactiveFormsModule,
} from '@angular/forms';
import { RouterLink } from '@angular/router';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import { faUser, faXmark } from '@fortawesome/free-solid-svg-icons';
import {
  EmployeeDetailsResult,
  EmployeeSearchDto,
} from '@models/employee.model';
import { EmployeeService } from '@services/employee.service';
import { padWithZeros } from '@utils/helpers';
import { ModalModule, BsModalService, BsModalRef } from 'ngx-bootstrap/modal';
import { PaginationModule } from 'ngx-bootstrap/pagination';
import { map, Subject, switchMap } from 'rxjs';

@Component({
  selector: 'app-search-employee',
  imports: [
    ReactiveFormsModule,
    ModalModule,
    FontAwesomeModule,
    RouterLink,
    PaginationModule,
    FormsModule,
  ],
  providers: [BsModalService],
  templateUrl: './search-employee.component.html',
  styleUrls: ['./search-employee.component.scss'],
  standalone: true,
})
export class SearchEmployeeComponent implements OnInit {
  private search$ = new Subject<EmployeeSearchDto | null>();
  searchForm: FormGroup;
  modalRef?: BsModalRef;
  employees: EmployeeDetailsResult[];
  employee: EmployeeDetailsResult;

  faXmark = faXmark;
  faUser = faUser;

  paginatedData: EmployeeDetailsResult[] = [];

  currentPage = 1;
  itemsPerPage = 10;

  constructor(
    private fb: FormBuilder,
    private api: EmployeeService,
    private modalService: BsModalService
  ) {}

  ngOnInit() {
    this.searchForm = this.fb.group({
      employeeId: [null],
      lastName: [null],
    });

    this.search$
      .pipe(
        switchMap((criteria) => {
          const payload = criteria ?? ({} as EmployeeSearchDto);

          return this.api
            .searchEmployee(payload)
            .pipe(map((r) => r.map((e) => ({ ...e, id: padWithZeros(e.id) }))));
        })
      )
      .subscribe({
        next: (r: EmployeeDetailsResult[]) => {
          this.employees = r;
          this.currentPage = 1;
          this.updatePaginatedData();
        },
        error: () => {
          this.employees = [];
          this.currentPage = 1;
        },
      });

    this.search$.next(null);
  }

  openModal(template: TemplateRef<void>, id: string) {
    this.employee = this.employees.find((e) => e.id == id)!;
    this.modalRef = this.modalService.show(template, this.employee);
  }

  onSubmit() {
    this.search$.next(this.searchForm.value as EmployeeSearchDto);
  }

  onPageChange(event: any): void {
    this.currentPage = event.page;
    this.updatePaginatedData();
  }

  updatePaginatedData(): void {
    const start = (this.currentPage - 1) * this.itemsPerPage;
    const end = start + this.itemsPerPage;
    this.paginatedData = this.employees.slice(start, end);
  }
}
