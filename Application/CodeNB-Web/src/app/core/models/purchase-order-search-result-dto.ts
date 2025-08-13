export class PurchaseOrderSearchResultDto {

    purchaseOrderNumber: string;
    purchaseOrderCreationDate: Date;
    purchaseOrderStatus: string;
    subtotal: number;
    taxTotal: number;
    grandTotal: number;
}
