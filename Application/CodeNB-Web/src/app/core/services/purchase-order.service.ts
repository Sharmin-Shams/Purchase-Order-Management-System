import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { catchError, Observable } from 'rxjs';
import { PurchaseOrder } from '@models/purchase-order';
import { API_URL, SharedService } from './shared.service';
import { PurchaseOrderSearchDto } from '@models/purchase-order-search-dto';
import { PurchaseOrderSearchResultDto } from '@models/purchase-order-search-result-dto';
import { PurchaseOrderDto } from '@models/purchase-order-dto';
import { POSupervisorSearchDTO } from '@models/posupervisor-search-dto';
import { POSupervisorSearchResultDTO } from '@models/posupervisor-search-result-dto';
import { SupervisorItemDecisionDTO } from '@models/supervisor-item-decision-dto';
import { UpdatePurchaseOrderRequest } from '@models/UpdatePurchaseOrderRequest';


@Injectable({
  providedIn: 'root',
})
export class PurchaseOrderService extends SharedService {

 // private apiUrl = 'http://localhost:5130/api/PurchaseOrder';
  constructor(private http: HttpClient) {
    super()
  }

  createPurchaseOrder(order: PurchaseOrder): Observable<PurchaseOrder> {
    return this.http.
       // post<PurchaseOrder>(this.apiUrl, order);
       post<PurchaseOrder>(`${API_URL}/PurchaseOrder`, order)
       .pipe(catchError(super.handleError));
  }
  
  searchPurchaseOrder(dto: PurchaseOrderSearchDto): Observable<PurchaseOrderSearchResultDto[]> {
    const params = new HttpParams({ fromObject: {
      purchaseOrderNumber: dto.purchaseOrderNumber ?? '',
      startDate: dto.startDate?.toString() ?? '',
      endDate: dto.endDate?.toString() ?? ''
    }});
  
    return this.http.
      get<PurchaseOrderSearchResultDto[]>(`${API_URL}/PurchaseOrder/search/criteria`, { params })
    .pipe(catchError(super.handleError));
  }


  getPurchaseOrderDetails(poNumber: number): Observable<PurchaseOrderDto> {
    return this.http
    .get<PurchaseOrderDto>(`${API_URL}/PurchaseOrder/${poNumber}/details`)
    .pipe(catchError(super.handleError));
  }

  searchSupervisorPOs(dto : POSupervisorSearchDTO): Observable<POSupervisorSearchResultDTO[]>{
    const params = new HttpParams({ fromObject: {
      PONumber: dto.poNumber ?? '',
      startDate: dto.startDate?.toString() ?? '',
      endDate: dto.endDate?.toString() ?? '',
      poStatus: dto.poStatus ?? '',
      employeeFullName: dto.employeeFullName ?? ''

    }});
    return this.http.
      get<POSupervisorSearchResultDTO[]>(`${API_URL}/PurchaseOrder/supervisor`, { params })
    .pipe(catchError(super.handleError));
  }
  
  processItemDecision(dto: SupervisorItemDecisionDTO): Observable<boolean> {
    return this.http.post<boolean>(`${API_URL}/PurchaseOrder/supervisor/item-decision`, dto)
    .pipe(catchError(super.handleError));
  }
  closePurchaseOrder(poNumber: number): Observable<any> {
    return this.http.post<any>(`${API_URL}/PurchaseOrder/supervisor/close`, poNumber);
  }

//   updatePurchaseOrder(id :number,updatedPurchaseOrder: PurchaseOrder): Observable<PurchaseOrder> {
// if (!updatedPurchaseOrder.recordVersion) {
//     console.warn('Missing recordVersion for concurrency check!');
//   } else {
//     console.log('Sending recordVersion:', updatedPurchaseOrder.recordVersion);
//   }
//   return this.http.put<PurchaseOrder>(`${API_URL}/PurchaseOrder/${id}`,updatedPurchaseOrder)
//         .pipe(catchError(super.handleError));
// }
  
// for merge item bug
updatePurchaseOrder(id: number,updatedPurchaseOrder: PurchaseOrder,deletedItemIds: number[]
): Observable<PurchaseOrder> {

  const body: UpdatePurchaseOrderRequest = {
    purchaseOrder: updatedPurchaseOrder,
    deletedItemIds: deletedItemIds
  };

  return this.http.put<PurchaseOrder>(`${API_URL}/PurchaseOrder/${id}`, body)
    .pipe(catchError(super.handleError));
}


}
