import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { FormsModule, NgForm } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { PurchaseOrderSearchDto } from '@models/purchase-order-search-dto';
import { PurchaseOrderService } from '@services/purchase-order.service';
@Component({
  selector: 'app-search',
  imports: [RouterModule,FormsModule,CommonModule],
  templateUrl: './search.component.html',
  styleUrl: './search.component.scss'
})
export class SearchComponent implements OnInit {

  criteria: PurchaseOrderSearchDto = {};
  results: any[] = [];
  error:string = "";

 
constructor(private poService: PurchaseOrderService,private router: Router){}


ngOnInit(): void {
  this.loadPurchaseOrder();
}
loadPurchaseOrder(){
  this.poService.searchPurchaseOrder(this.criteria).subscribe({
   
    
    next: res => {
      this.results = res;
      console.log(res)
      
      this.error = '';
    },
    error: err => {
     
        this.results = [];
        this.error = err.error?.message || 'No purchase orders found.';
      }
    
    } );
}


search(form: NgForm) {
this.error='';
if (this.criteria.startDate && this.criteria.endDate) {
  if (new Date(this.criteria.startDate) > new Date(this.criteria.endDate)) {
    this.error="Start date cannot be after end date.";
    this.results = [];
    return;
  }
}
  if (this.criteria.purchaseOrderNumber && this.criteria.purchaseOrderNumber?.length != 8) {
    console.log(this.criteria);
    this.error = 'Purchase order number starts from 00000101.';
    this.results = [];
    return;
  }else if((this.criteria.purchaseOrderNumber && this.criteria.purchaseOrderNumber?.length == 8)||
  (this.criteria.purchaseOrderNumber?.trim().length==0 )||!this.criteria.endDate==null||this.criteria.startDate==null||this.criteria.purchaseOrderNumber==null ){
    // this.poService.searchPurchaseOrder(this.criteria).subscribe({
   
    
    //   next: res => {
    //     this.results = res;
    //     console.log(res)
        
    //     this.error = '';
    //   },
    //   error: err => {
       
    //       this.results = [];
    //       this.error = err.error?.message || 'No purchase orders found.';
    //     }
      
    //   } );
      this.loadPurchaseOrder();
    this.error = ''; // Clear previous errors
  
  
  } else{
    console.log(this.criteria); console.log("else");
  }

}

reset(form: NgForm){
   form.resetForm();
   this.results=[];
   this.error= "";
}

goToDetails(poNumber: number) {
  this.router.navigate(['/po/details', poNumber], {
    state: { poList: this.results }
  });
}

}
