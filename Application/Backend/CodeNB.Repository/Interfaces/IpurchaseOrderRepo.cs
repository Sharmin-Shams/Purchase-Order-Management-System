using CodeNB.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Repository
{
    public interface IpurchaseOrderRepo
    {
      Task<PurchaseOrder> CreatePurchaseOrderAsync(PurchaseOrder purchaseOrder);

       Task<List<DepartmentSearchResultDto>> GetPurchaseOrderByDepartment(int departmentId);

        Task<List<PurchaseOrderSearchResultDto>> SearchEmployeePurchaseOrdersAsync(PurchaseOrderSearchDto criteria);

        Task<PurchaseOrderDto> GetPurchaseOrderDetails(int poNumber);

        Task<List<POSupervisorSearchResultDTO>> SearchPurchaseOrderBySupervisor(POSupervisorSearchDTO criteria);
        Task<bool> ProcessItemDecision(SupervisorItemDecisionDTO dto);
        Task  ClosePurchaseOrderAsync(int purchaseOrderNumber);
        Task<string> GetEmployeeEmailForPOAsync(int purchaseOrderNumber);

        // Task<PurchaseOrder> UpdatePurchaseOrder(PurchaseOrder purchaseOrder);

        Task<PurchaseOrder> UpdatePurchaseOrder(PurchaseOrder purchaseOrder, List<int> deletedItemIds);

    }
}
