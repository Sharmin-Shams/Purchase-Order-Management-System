using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public class PurchaseOrderDto
    {

        public string PurchaseOrderNumber { get; set; } 
        public string? EmployeeFullName { get; set; } 
        public string? DepartmentName { get; set; } 
        public string? SupervisorFullName { get; set; } 
        public DateTime CreationDate { get; set; }
        public string PurchaseStatus { get; set; }
        public int EmployeeID { get; set; }
        public List<PurchaseOrderItemDto> Items { get; set; } = new();
        public byte[]? RecordVersion { get; set; }
        public decimal Subtotal { get; set; }
        public decimal TaxTotal { get; set; }
        public decimal GrandTotal { get; set; }
    }
}
