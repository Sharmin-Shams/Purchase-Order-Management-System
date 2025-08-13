import { PurchaseOrderItem } from './purchase-order-item';

export class PurchaseOrder {

  purchaseOrderNumber: number = 0;
  employeeID: number = 0;
  creationDate: Date = new Date();
  taxRate: number = 0;
  recordVersion?: string;
  purchaseOrderStatusID: number = 1;
  items: PurchaseOrderItem[] = [];
}
