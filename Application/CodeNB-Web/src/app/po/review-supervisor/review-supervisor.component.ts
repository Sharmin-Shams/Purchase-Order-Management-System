import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { PurchaseOrder } from '@models/purchase-order';
import { PurchaseOrderDto } from '@models/purchase-order-dto';
import { PurchaseOrderService } from '@services/purchase-order.service';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-review-supervisor',
  imports: [FormsModule,CommonModule,RouterModule],
  templateUrl: './review-supervisor.component.html',
  styleUrl: './review-supervisor.component.scss'
})
export class ReviewSupervisorComponent {

  purchaseOrder: PurchaseOrderDto | null = null;
  error = '';
  id: number ;
  subs: Subscription[] = [];
  poList: PurchaseOrderDto[] = []
  loading: boolean = false;
  deletedItemIds: number[] = [];
  editRowIndex: number |null= null;
  constructor(
    private route: ActivatedRoute,
    private poService: PurchaseOrderService,
    private router: Router
  ) {}

  ngOnInit(): void {
    
    const routeSub = this.route.params.subscribe(params => {
      this.id = +params['id'];
     
     this.poList = (history.state.poList || []).map((po: any) => ({
  ...po,
  purchaseOrderNumber: +po.poNumber
}));
      
      this.loadPurchaseOrder();
    });

    this.subs.push(routeSub);
  }

  loadPurchaseOrder(): void {
    const getSub = this.poService.getPurchaseOrderDetails(this.id).subscribe({
      next: res =>{ this.purchaseOrder = res,
      console.log(res);
      this.purchaseOrder.items.forEach(item => {
        item.originalQuantity = item.itemQuantity;
        item.originalPrice = item.itemPrice;
        item.originalLocation = item.itemPurchaseLocation;
      });
      },
      
      error: err => {
        if (err.status === 404) {
          this.error = 'Purchase Order not found or access denied.';
        } else {
          this.error = 'An error occurred while loading the purchase order.';
        }
      }
    });

    this.subs.push(getSub)
  }

  ngOnDestroy(): void {
    this.subs.forEach(s => s.unsubscribe());
  }

  getAdjacentPO(direction: 'next' | 'previous'): number | null {
    
    const index = this.poList.findIndex(po => +po.purchaseOrderNumber === this.id);
    
    const newIndex = direction === 'next' ? index + 1 : index - 1;
    if (newIndex >= 0 && newIndex < this.poList.length) {
      return +this.poList[newIndex].purchaseOrderNumber;
    }
    return null;
  }

  canNavigate(direction: 'next' | 'previous'): boolean {
    return this.getAdjacentPO(direction) !== null;
  }

  goTo(direction: 'next' | 'previous') {
    const nextId = this.getAdjacentPO(direction);
   
    if (nextId !== null) {
      this.router.navigate(['/po/review', nextId], {
        state: { poList: this.poList }
      });
    }
  }

  deny(item: any,index:number): void {

    if (this.editRowIndex === index) {
    alert('Please save your changes before approving this item.');
    return;
  }
    if (!item.denialReason) {
      alert('Denial reason required');
      return;
    }
    this.processItem(item, 3); // 3 = Denied
  }

  approve(item: any,index: number): void {

     if (this.editRowIndex === index) {
    alert('Please save your changes before approving this item.');
    return;
  }
    this.processItem(item, 2); // 2 = Approved
  }
processItem(item:any, updatedStatusID : number):void{
  const dto = {
    itemID: item.id,
    updatedItemStatusID:updatedStatusID,
    denialReason: item.denialReason ?? null
  }
 
this.poService.processItemDecision(dto).subscribe({
  
  next: (isLastItem: boolean) => {
    item.itemStatusID = updatedStatusID;
    item.itemStatus = updatedStatusID === 2 ? 'Approved' : 'Denied';
 alert(`Item has been ${item.itemStatus}.`);
    if (this.purchaseOrder!.purchaseStatus === 'Pending') {
      this.purchaseOrder!.purchaseStatus = 'Under Review';
    }
    // if (isLastItem){
    //   this.confirmAndClosePO();
    // }
this.loadPurchaseOrder();
    if (isLastItem){
      setTimeout(()=>{
        this.confirmAndClosePO();
      },0)
      
    }
  },
  error: () => alert('Error updating item status.')
});
}
canManuallyClosePO(): boolean {
  if (!this.purchaseOrder) return false;

  const allProcessed = this.purchaseOrder.items.every(item => item.itemStatus !== "Pending"); 
  return this.purchaseOrder.purchaseStatus === 'Under Review' && allProcessed;
}
closePO(): void {
  this.confirmAndClosePO();
}


confirmAndClosePO(): void {
  if (!this.purchaseOrder) return;

  const confirmed = confirm('Are you sure you want to close this purchase order?');
  if (!confirmed) return;
 this.loading=true;
  this.poService.closePurchaseOrder(+this.purchaseOrder.purchaseOrderNumber).subscribe({
    next: () => {
      this.purchaseOrder!.purchaseStatus = 'Closed';
      alert('Purchase Order closed and employee notified.');
      this.loading = false;
    },
    error: err => {
      alert(err.error?.error || 'Failed to close the purchase order.');
      this.loading = false;
    }
  });
}
canCloseIfAllDenied(): boolean {
  if (!this.purchaseOrder) return false;

  const hasItems = this.purchaseOrder.items.length > 0;
  const allDenied = this.purchaseOrder.items.every(item => item.itemStatus === 'Denied');

  return this.purchaseOrder.purchaseStatus === 'Pending' && hasItems && allDenied;
}

//for save changes

saveChanges(onSuccess?: () => void): void {
  this.error= "";
  if (!this.purchaseOrder) return;


  const updatedPurchaseOrder: PurchaseOrder = {
    purchaseOrderNumber: +this.purchaseOrder.purchaseOrderNumber,
    creationDate: this.purchaseOrder.creationDate,
    employeeID: this.purchaseOrder.employeeID, 
    taxRate: 0.15,       
    recordVersion: this.purchaseOrder.recordVersion,
    purchaseOrderStatusID: this.mapStatusToId(this.purchaseOrder.purchaseStatus),
    items: this.purchaseOrder.items.map(item => ({
      id: item.id,
      itemName: item.itemName,
      itemQuantity: item.itemQuantity,
      itemDescription: item.itemDescription,
      itemPrice: item.itemPrice,
      itemJustification: item.itemJustification,
      itemPurchaseLocation: item.itemPurchaseLocation,
      purchaseOrderItemStatusID: this.mapStatusToId(item.itemStatus),
      purchaseOrderID:+ this.purchaseOrder!.purchaseOrderNumber,
      denialReason: item.denialReason ?? undefined,
      modificationReason: item.modificationReason ?? undefined

      
    }))
  };
console.log(updatedPurchaseOrder);


  this.poService.updatePurchaseOrder(
    updatedPurchaseOrder.purchaseOrderNumber,
    updatedPurchaseOrder,
    this.deletedItemIds
    
  ).subscribe({
    next: () => {
      alert('Changes saved successfully.');
      this.deletedItemIds = [];
      this.loadPurchaseOrder(); 
       if (onSuccess) onSuccess();
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
    }
  });
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
onEditOrSave(item: any, index: number): void {
  if (this.editRowIndex === index) {
   // Validate this row
    if (
      !item.itemQuantity || item.itemQuantity < 1 ||
      !item.itemPrice || item.itemPrice < 0.01 ||
      !item.itemPurchaseLocation || item.itemPurchaseLocation.length < 5 
      
    ) {
      alert("Please input the missing value")
      return;
    }
    const isModified =
      item.itemQuantity !== item.originalQuantity ||
      item.itemPrice !== item.originalPrice ||
      item.itemPurchaseLocation !== item.originalLocation;

  if (isModified &&
  (!item.modificationReason || item.modificationReason.trim() === '') ){
    alert('Please provide a modification reason.');
    return;
  }

    // if (!item.modificationReason?.trim()) {
    //   alert('Modification reason is required before saving.');
    //   return;
    // }
    // Save and exit edit mode after success
    this.saveChanges(() => {
      this.editRowIndex = null;
    });

  } else {
    this.editRowIndex = index;
    item.modificationReason="";
  }
}

}