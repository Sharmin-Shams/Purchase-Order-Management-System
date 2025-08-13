using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public class PurchaseOrderStatus :BaseEntity
    {
        public int ID { get; set; }

        public string StatusName { get; set; }
    }
}
