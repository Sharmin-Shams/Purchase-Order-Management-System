import { CommonModule } from '@angular/common';
import { Component, OnDestroy, OnInit } from '@angular/core';

import { FormsModule, NgForm, ReactiveFormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { EmployeeAssignment } from '@models/employee.model';
import { PurchaseOrder } from '@models/purchase-order';
import { PurchaseOrderItem } from '@models/purchase-order-item';
import { ValidationError } from '@models/validation-error';
import { AuthenticationService } from '@services/authentication.service';
import { EmployeeService } from '@services/employee.service';
import { PurchaseOrderService } from '@services/purchase-order.service';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-create',
  imports: [FormsModule,CommonModule,RouterModule],
  
  templateUrl: './create.component.html',
  styleUrl: './create.component.scss',
  standalone: true,
})
export class CreateComponent implements OnInit,OnDestroy {
  purchaseOrder: PurchaseOrder = new PurchaseOrder();
  newItem: PurchaseOrderItem = new PurchaseOrderItem();
  message = '';
  subtotal = 0;
  tax = 0.15;
  total = 0;
  taxTotal =0;
  employeeFullName: string | undefined= "";
  departmentName : string |undefined="";
  supervisorFullName: string |undefined ="";
  errors: string[] = [];
  fieldErrors: { [key: string]: string } = {};
  today: Date = new Date();
  employeeAssignment?: EmployeeAssignment
  
  constructor(
    private purchaseOrderService: PurchaseOrderService, 
    private authService: AuthenticationService,
    private employeeService: EmployeeService){}
 

  ngOnInit(): void {
    const id = this.authService.getUserId(); // get user ID from JWT or session

  if (id) {
    this.employeeService.getEmployeeAssignment(id).subscribe({
      next: (res) => {
        this.employeeAssignment = res;
        console.log('Employee assignment response:', res); 
       
        this.employeeFullName = res.employeeName;
        
       this.departmentName = res.departmentName
        this.supervisorFullName = res.supervisorName
       },
      error: (err) => {
        console.error('Failed to load employee assignment', err);
        this.message = 'Unable to load employee information.';
      }
    });
  }
    
    
  }
  ngOnDestroy(): void {
    
  }
  addItem(form: NgForm) {
    if (form.invalid) {
      Object.values(form.controls).forEach(c => c.markAsTouched());
      return;
    }
    this.fieldErrors = {};
    const matchItem = this.purchaseOrder.items.find(item =>
      item.itemName === this.newItem.itemName &&
      item.itemDescription === this.newItem.itemDescription &&
      item.itemPrice === this.newItem.itemPrice &&
      item.itemJustification === this.newItem.itemJustification &&
      item.itemPurchaseLocation === this.newItem.itemPurchaseLocation
    );

    if (matchItem) {
      matchItem.itemQuantity += this.newItem.itemQuantity;
    } else {
      this.purchaseOrder.items.push({ ...this.newItem });
    }

    this.calculateTotals();
    form.resetForm();
    this.newItem = new PurchaseOrderItem();
    this.message="";
    this.errors = [];
  }
  deleteItem(index: number): void {
    this.purchaseOrder.items.splice(index, 1);
    this.calculateTotals();
  }

  calculateTotals() {
    this.subtotal = this.purchaseOrder.items.reduce((sum, item) =>
      sum + item.itemPrice * item.itemQuantity, 0);
  
    this.taxTotal = this.subtotal * this.tax;
    this.total = this.subtotal + this.taxTotal;
  
    //  rounding
    this.subtotal = Math.round(this.subtotal * 100) / 100;
    this.tax = Math.round(this.tax * 100) / 100;
    this.total = Math.round(this.total * 100) / 100;
  }
  
  submit() {
    this.message = '';
    this.errors = [];
    this.fieldErrors = {};
    this.subtotal = 0;
    this.taxTotal = 0;
    this.total = 0;
    if (this.purchaseOrder.items.length === 0) {
      this.message = 'You must add at least one item.';
      return;
    }
    this.purchaseOrderService.createPurchaseOrder(this.purchaseOrder).subscribe({
      next: (res:any) => {
        this.message = `${res.message} Purchase Order Number: ${res.purchaseOrderNumber}`;
        this.purchaseOrder = new PurchaseOrder(); // clear form 
        this.newItem = new PurchaseOrderItem();
      },
      error: (err) => {
        const validationErrors: ValidationError[] = err.error?.errors;
        if (Array.isArray(validationErrors)) {
          for (const e of validationErrors) {
            const field = e.field?.trim();
            const msg = e.message||e.description || 'Validation error';
            if (field) {
              this.fieldErrors[field] = msg;
            } else {
              this.errors.push(msg);
            }
          }
        } else {
          this.errors.push(err.error?.title || 'An unexpected error occurred.');
        }
      }
    });

  }

  reset(form: NgForm){
    form.resetForm();
    this.purchaseOrder = new PurchaseOrder();
    this.newItem = new PurchaseOrderItem();
    this.message = '';
 
  this.subtotal = 0;
  this.taxTotal = 0;
  this.total = 0;
 }
}
