using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model.Dtos
{
    public class PurchaseOrderUpdateRequest
    {
        public PurchaseOrder PurchaseOrder { get; set; }
        public List<int> deletedItemIds { get; set; } = new();
    }
}
