export class PurchaseOrderItem {
  id: number;
  purchaseOrderID :number;
  itemName?: string;
  itemDescription?: string;
  itemQuantity: number;
  itemPrice: number;
  itemJustification?: string;
  purchaseOrderItemStatusID: number;
  itemPurchaseLocation?: string;
  recordVersion?: string;
  denialReason? :string
  modificationReason?:string;
}
