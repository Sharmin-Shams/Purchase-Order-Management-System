import { PurchaseOrderItemDto } from "./purchase-order-item-dto";

export class PurchaseOrderDto {

    purchaseOrderNumber: string = '';
    employeeFullName?: string;
    departmentName?: string;
    supervisorFullName?: string;
    creationDate: Date = new Date();
    purchaseStatus: string = '';
    employeeID: number;
    recordVersion?: string;
    items: PurchaseOrderItemDto[] = [];
    subtotal: number = 0;
    taxTotal: number = 0;
    grandTotal: number = 0;
}
