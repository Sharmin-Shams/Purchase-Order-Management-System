using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public class PurchaseOrder : BaseEntity
    {

        [Key]
        public int PurchaseOrderNumber { get; set; } 

        [Required(ErrorMessage = "Employee is required.")]
        public int EmployeeID { get; set; }

        [Required(ErrorMessage = "Creation date is required.")]
        public DateTime CreationDate { get; set; } = DateTime.Now;
        [Required(ErrorMessage = "Tax rate is required.")]

        public decimal TaxRate { get; set; }
        public byte[]? RecordVersion { get; set; }

        [Required(ErrorMessage = "Purchase order status  is required.")]
        public int PurchaseOrderStatusID { get; set; } = 1;

        public List<PurchaseOrderItem> Items { get; set; } = new();


    }
}
