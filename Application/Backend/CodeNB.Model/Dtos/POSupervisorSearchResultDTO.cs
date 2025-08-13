using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public class POSupervisorSearchResultDTO
    {
        public string PONumber { get; set; }
        public DateTime CreationDate { get; set; }
        public string EmployeeFullName { get; set; } = string.Empty;
        public string POStatus { get; set; } = string.Empty;
        public decimal SubTotal { get; set; }
        public decimal TaxTotal { get; set; }
        public decimal GrandTotal { get; set; }
    }
}
