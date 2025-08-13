using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public class DepartmentSearchResultDto
    {
        public string PurchaseOrderNumber { get; set; } 
        public DateTime CreationDate { get; set; }
        public string SupervisorName { get; set; } 
        public string PurchaseOrderStatus { get; set; } 

    }
}
