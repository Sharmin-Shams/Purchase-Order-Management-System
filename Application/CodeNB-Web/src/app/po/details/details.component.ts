import { CommonModule } from '@angular/common';
import { Component, OnDestroy, OnInit } from '@angular/core';
import { AbstractControl, FormArray, FormBuilder, FormGroup, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { PurchaseOrder } from '@models/purchase-order';
import { PurchaseOrderDto } from '@models/purchase-order-dto';
import { PurchaseOrderService } from '@services/purchase-order.service';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-details',
  imports: [FormsModule,CommonModule,RouterModule,ReactiveFormsModule],
  templateUrl: './details.component.html',
  styleUrl: './details.component.scss'
})
export class DetailsComponent implements OnInit, OnDestroy {

 purchaseOrder: PurchaseOrderDto | null = null;
 // updatedPurchaseOrder: PurchaseOrder| null = null;
  form!: FormGroup;
  error = '';
  id!: number;
  subs: Subscription[] = [];
  poList: PurchaseOrderDto[] = [];
   editRowIndex: number | null = null;
// added for existing merge item bug
  deletedItemIds: number[] = [];

  constructor(
    private route: ActivatedRoute,
    private poService: PurchaseOrderService,
    private router: Router,
    private fb: FormBuilder
  ) {}

  ngOnInit(): void {
    this.poList = history.state.poList || [];

    const routeSub = this.route.params.subscribe(params => {
      this.id = +params['id'];
      this.loadPurchaseOrder();
    });
    this.subs.push(routeSub);
  }


  ngOnDestroy(): void {
    this.subs.forEach(s => s.unsubscribe());
  }
  loadPurchaseOrder(): void {
    this.deletedItemIds = [];
    const getSub = this.poService.getPurchaseOrderDetails(this.id).subscribe({
      next: res => {
        this.purchaseOrder = res;
        
        
      //  this.buildForm(res);
        this.form = this.fb.group({
          items: this.fb.array([])
        });
        res.items.forEach(item => {
          this.items.push(this.createItemFormGroup(item));
        });
      },
      error: err => {
        this.error = err.status === 404
          ? 'Purchase Order not found or access denied.'
          : 'An error occurred while loading the purchase order.';
      }
    });
    this.subs.push(getSub);
  }
  get items(): FormArray {
    return this.form.get('items') as FormArray;
  }
 createItemFormGroup(item: any): FormGroup {
  const isNoLongerNeeded = item.itemDescription?.trim().toLowerCase() === 'no longer needed';
    return this.fb.group({
      id: [item.id || 0],
      itemName: [item.itemName || '', [Validators.required, Validators.minLength(3), Validators.maxLength(45)]],
      itemQuantity: [item.itemQuantity ?? "", [Validators.required, Validators.min(isNoLongerNeeded ? 0 : 1)]],
      itemDescription: [item.itemDescription || '', [Validators.required, Validators.minLength(5)]],
      itemPrice: [item.itemPrice ?? "", [Validators.required, Validators.min(isNoLongerNeeded ? 0 : 0.01)]],
      itemJustification: [item.itemJustification || '', [Validators.required, Validators.minLength(4)]],
      itemPurchaseLocation: [item.itemPurchaseLocation || '', [Validators.required, Validators.minLength(5)]],
      itemStatus: [item.itemStatus || 'Pending'],
      denialReason: [item.denialReason || ''],
    recordVersion: [item.recordVersion || null],
    markAsNoLongerNeeded: [false]
    });
  }

  getAdjacentPO(direction: 'next' | 'previous'): number | null {
    const index = this.poList.findIndex(po => +po.purchaseOrderNumber === this.id);
    const newIndex = direction === 'next' ? index + 1 : index - 1;
    return newIndex >= 0 && newIndex < this.poList.length ? +this.poList[newIndex].purchaseOrderNumber : null;
  }

  canNavigate(direction: 'next' | 'previous'): boolean {
    return this.getAdjacentPO(direction) !== null;
  }

  goTo(direction: 'next' | 'previous') {
    const nextId = this.getAdjacentPO(direction);
    if (nextId !== null) {
      this.router.navigate(['/po/details', nextId], {
        state: { poList: this.poList }
      });
    }
  }

   isEditable(): boolean {
    return this.purchaseOrder?.purchaseStatus === 'Pending' || this.purchaseOrder?.purchaseStatus === 'Under Review';
  }

  canEditItem(item: AbstractControl): boolean {
    const group = item as FormGroup;
    return this.isEditable() && group.get('itemStatus')?.value === 'Pending';
  }

  addEmptyItemRow(): void {
    if (!this.isEditable()) return;
    const newItem = this.createItemFormGroup({});
    this.items.push(newItem);
    this.editRowIndex = this.items.length - 1;
  }

  saveNewItem(index: number): void {
    const newItem = this.items.at(index);
    if (!newItem.valid) {
      newItem.markAllAsTouched();
      return;
    }

    const newValues = newItem.value;

    const existing = this.items.controls.find((ctrl, i) => {
      const val = ctrl.value;
      return (
        i !== index &&
        val.itemStatus === 'Pending' &&
        val.itemName === newValues.itemName &&
        val.itemDescription === newValues.itemDescription &&
        val.itemPrice === newValues.itemPrice &&
        val.itemJustification === newValues.itemJustification &&
        val.itemPurchaseLocation === newValues.itemPurchaseLocation
      );
    });

    if (existing) {
      const currentQty = +existing.get('itemQuantity')!.value;
      const newQty = +newItem.get('itemQuantity')!.value;
      existing.get('itemQuantity')!.setValue(currentQty + newQty);
// tracked merged ID if the merged item exists in DB
const deletedId = newItem.get('id')?.value;
    if (deletedId && deletedId !== 0) {
      this.deletedItemIds.push(deletedId);
    }

      this.items.removeAt(index);
    }

    this.editRowIndex = null;
  }

  removeItem(index: number): void {
    this.items.removeAt(index);
    if (this.editRowIndex === index) this.editRowIndex = null;
  }

  markItemAsNotRequired(index: number): void {
    const item = this.items.at(index);
    if (item) {
      item.patchValue({
       itemQuantity: 0,
      itemPrice: 0,
      itemDescription: 'No longer needed',
      itemStatus: 'Denied',
     
      markAsNoLongerNeeded: true
      });
       item.get('itemQuantity')?.setValidators([Validators.required, Validators.min(0)]);
      item.get('itemPrice')?.setValidators([Validators.required, Validators.min(0)]);
      item.get('itemQuantity')?.updateValueAndValidity();
      item.get('itemPrice')?.updateValueAndValidity();    
    }
  }

  saveChanges(): void {
   
    if (!this.purchaseOrder || !this.form.valid) return;

    const updatedPurchaseOrder: PurchaseOrder = {
     
      
    purchaseOrderNumber: +this.purchaseOrder.purchaseOrderNumber,
    creationDate: this.purchaseOrder.creationDate,
    employeeID: this.purchaseOrder.employeeID,
    taxRate: 0.15,
   recordVersion: this.purchaseOrder.recordVersion!,
    purchaseOrderStatusID: this.mapStatusToId(this.purchaseOrder.purchaseStatus),
    items: this.items.value.map((item: any) => ({
      id: item.id,
      itemName: item.itemName,
      itemQuantity: item.itemQuantity,
      itemDescription: item.itemDescription,
      itemPrice: item.itemPrice,
      itemJustification: item.itemJustification,
      itemPurchaseLocation: item.itemPurchaseLocation,
      purchaseOrderItemStatusID: this.mapStatusToId(item.itemStatus),
      purchaseOrderID: +this.purchaseOrder!.purchaseOrderNumber,
      denialReason:item.denialReason,
      
       markAsNoLongerNeeded: item.markAsNoLongerNeeded
    }))
  }
   console.log(updatedPurchaseOrder);
    // const updatedPurchaseOrder = {
    //   ...this. updatedPurchaseOrder,
    //   items: this.items.value
    // };
   
    this.poService.updatePurchaseOrder(this.id,updatedPurchaseOrder,this.deletedItemIds).subscribe({
      next: () => {
        alert('Changes saved successfully.');
        this.deletedItemIds = [];
        this.loadPurchaseOrder();
      },
      error: (err) => {
        const errors = err?.error?.errors;

  if (Array.isArray(errors) && errors.length > 0) {
    
    this.error = errors.map((e: any) => e.description).join('\n');
  } else if (err?.error?.message) {
    
    this.error = err.error.message;
  } else {
    this.error = 'Failed to save changes. Please try again.';
  }
         console.error('Update error:', err);
       // this.error = err?.error.message ||'Failed to save changes. Please try again.';
      }
    });
  }

  get subtotal(): number {
    return this.items.controls.reduce((sum, item) => {
      const group = item as FormGroup;
      const status = group.get('itemStatus')?.value;
      if (status === 'Denied') return sum;
      const price = +group.get('itemPrice')?.value || 0;
      const qty = +group.get('itemQuantity')?.value || 0;
      return sum + (price * qty);
    }, 0);
  }

  get taxTotal(): number {
    return this.subtotal * 0.15;
  }

  get grandTotal(): number {
    return this.subtotal + this.taxTotal;
  }
mapStatusToId(status: string): number {
  switch (status) {
    case 'Pending': return 1;
    case 'Approved': return 2;
    case 'Denied': return 3;
    case 'Under Review': return 4;
    case 'Closed': return 5;
    default: return 1;
  }
}

get isPurchaseOrderClosed(): boolean {
  return this.purchaseOrder?.purchaseStatus === 'Closed';
}

}