export class PurchaseOrderItemDto {

  id:number;
  purchaseOrderID :number;
  itemName: string = '';
  itemDescription: string = '';
  itemQuantity: number = 0;
  itemPrice: number = 0;
  itemJustification: string = '';
  itemStatus: string = '';
  itemPurchaseLocation: string = '';
  recordVersion?: string;
  itemSubtotal: number = 0;
  itemTaxTotal: number = 0;
  itemGrandTotal: number = 0;
  denialReason? :string
  modificationReason?:string;
  originalQuantity:number=0;
  originalPrice:number=0;
  originalLocation:string="";
  
}
