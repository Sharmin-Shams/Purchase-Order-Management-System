using CodeNB.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Service
{
    public interface IPurchaseOrderService
    {
       
        Task<PurchaseOrder> CreatePurchaseOrderAsync(PurchaseOrder purchaseOrder);
        Task<List<DepartmentSearchResultDto>> GetPurchaseOrderByDepartment(int departmentId);
        Task<List<PurchaseOrderSearchResultDto>> GetPurchaseOrders(PurchaseOrderSearchDto criteria);

        Task<PurchaseOrderDto> GetPurchaseOrderDetails(int poNumber);
        Task<List<POSupervisorSearchResultDTO>> SearchPurchaseOrderBySupervisor(POSupervisorSearchDTO criteria);
        Task<bool> ProcessItemDecisionAsync(SupervisorItemDecisionDTO dto);
        Task ClosePurchaseOrderAsync(int purchaseOrderNumber);
        //Task<PurchaseOrder> UpdatePurchaseOrder(PurchaseOrder purchaseOrder);
        //for track merge items
        Task<PurchaseOrder> UpdatePurchaseOrder(PurchaseOrder purchaseOrder, List<int> deletedItemIds);
    }
}
