using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public class PurchaseOrderItemDto
    {

        public int ID { get; set; }
        public int PurchaseOrderID { get; set; }

        public string ItemName { get; set; }

        public string ItemDescription { get; set; }

        public int ItemQuantity { get; set; }

        public decimal ItemPrice { get; set; }

        public string ItemJustification { get; set; }

        public string ItemStatus { get; set; }

        public string ItemPurchaseLocation { get; set; }
        public byte[]? RecordVersion { get; set; }
        public decimal ItemSubtotal { get; set; }
        public decimal ItemTaxTotal { get; set; }
        public decimal ItemGrandTotal { get; set; }

        public string? DenialReason { get; set; }
        public string? ModificationReason { get; set; }


    }
}
