import { PurchaseOrder } from "./purchase-order";

export class UpdatePurchaseOrderRequest {
  purchaseOrder: PurchaseOrder;
  deletedItemIds: number[];
}