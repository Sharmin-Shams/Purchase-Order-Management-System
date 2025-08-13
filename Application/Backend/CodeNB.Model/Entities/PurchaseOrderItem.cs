using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public class PurchaseOrderItem : BaseEntity
    {
        public int ID { get; set; }
        public int PurchaseOrderID { get; set; }

        [Required(ErrorMessage = "Item name is required.")]
        [StringLength(45, MinimumLength = 3, ErrorMessage = "Item name must be between 3 and 45 characters.")]  
        public string? ItemName { get; set; }

        [Required(ErrorMessage = "Item description is required.")]
        [StringLength(255, MinimumLength = 5, ErrorMessage = "Item description must be at least 5 characters.")]
        public string? ItemDescription { get; set; } 

       // [Required(ErrorMessage = "Item quantity is required.")]
        //[Range(1, int.MaxValue, ErrorMessage = "Item quantity must be greater than zero.")]
        [ConditionalQuantityValidationAttribute]
        public int ItemQuantity { get; set; }

        //[Required(ErrorMessage = "Item price is required.")]
        //[Range(0.01, double.MaxValue, ErrorMessage = "Item price must be greater than zero.")]
        [ConditionalPriceValidationAttribute]
        public decimal ItemPrice { get; set; }

        [Required(ErrorMessage = "Item justification is required.")]
        [StringLength(255, MinimumLength = 4, ErrorMessage = "Item justification must be at least 4 characters.")]
        public string? ItemJustification { get; set; }

        [Required(ErrorMessage = "Item status is required.")]
        public int PurchaseOrderItemStatusID { get; set; } = 1;

        [Required(ErrorMessage = "Item purchase location is required.")]
        [StringLength(255, MinimumLength = 5, ErrorMessage = "Item purchase location must be at least 5 characters.")]
        public string? ItemPurchaseLocation { get; set; }
        public string? DenialReason { get; set; }
        public byte[]? RecordVersion { get; set; }
        public string? ModificationReason { get; set; }

    }
}
