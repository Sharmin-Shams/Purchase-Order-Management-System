import { CommonModule, NgClass } from '@angular/common';
import { Component } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { POSupervisorSearchDTO } from '@models/posupervisor-search-dto';
import { POSupervisorSearchResultDTO } from '@models/posupervisor-search-result-dto';

import { PurchaseOrderService } from '@services/purchase-order.service';


@Component({
  selector: 'app-search-supervisor',
  imports: [ReactiveFormsModule,CommonModule],
  templateUrl: './search-supervisor.component.html',
  styleUrl: './search-supervisor.component.scss'
})
export class SearchSupervisorComponent {

  searchForm!: FormGroup;
  results: POSupervisorSearchResultDTO[] = [];
  searched = false;
  error = '';

  constructor(private fb: FormBuilder, private poService: PurchaseOrderService,private router: Router) {}

  ngOnInit(): void {
    
    this.searchForm = this.fb.group({
      poNumber: ['', [Validators.pattern(/^\d{8}$/)]],
      startDate: [''],
      endDate: [''],
      status: ['Pending'],
      employeeName: ['']
    });

    this.onSearch(); 
  }

  onSearch(): void {
    this.error = '';
    const formValues = this.searchForm.value;
    const rawPo = formValues.poNumber;
    const dto: POSupervisorSearchDTO = {
      poNumber: formValues.poNumber ? formValues.poNumber.padStart(8, '0') : null,
      startDate: formValues.startDate,
      endDate: formValues.endDate,
      poStatus: formValues.status,
      employeeFullName: formValues.employeeName
    };
    if (rawPo && rawPo.length !== 8) {
      this.error = 'Purchase order number starts from 00000101.';
      this.results = [];
      return;
    }
    if (dto.startDate && dto.endDate) {
      const startDate = new Date(dto.startDate);
      const endDate = new Date(dto.endDate);
  
      if (isNaN(startDate.getTime()) || isNaN(endDate.getTime())) {
        this.error = 'One or both dates are invalid.';
        this.results = [];
        return;
      }
  
      if (startDate > endDate) {
        this.error = 'Start date cannot be after end date.';
        this.results = [];
        return;
      }
    }
  
    this.poService.searchSupervisorPOs(dto).subscribe({
      next: (data) => {
        this.results = data;
        this.searched = true;
  
        if (this.results.length === 0) {
          this.error = 'No matching purchase orders found.';
        } else {
          this.error = '';
        }
      },
      error: (err) => {
        this.results = [];
        this.searched = true;
        this.error = err.error?.message || 'Search failed. Please try again.';
        console.error('Search failed', err);
      }
    });
  }
  onClear(): void {
    this.searchForm.reset({
      poNumber: '',
      startDate: '',
      endDate: '',
      status: 'Pending',
      employeeName: ''
    });
  
    this.results = [];
    this.error = '';
    this.searched = false;
  }

  goToDetails(poNumber: number) {
    this.router.navigate(['/po/review', poNumber], {
      state: { poList: this.results }
    });
  }
}