using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
   public class PurchaseOrderSearchResultDto
    {

        public string PurchaseOrderNumber { get; set; }
        public DateTime PurchaseOrderCreationDate { get; set; }
        public string PurchaseOrderStatus { get; set; } 
        public decimal Subtotal { get; set; }
        public decimal TaxTotal { get; set; }
        public decimal GrandTotal { get; set; }
    }
}
