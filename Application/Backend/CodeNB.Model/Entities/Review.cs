using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public class Review : BaseEntity
    {
        public int ID { get; set; }
        public int Year { get; set; }
        public int Quarter { get; set; }

        public int EmployeeID { get; set; }
        public int SupervisorID { get; set; }

        [Required]
        [Display(Name = "Rating")]
        public int? RatingID { get; set; }

        [Required]
        public string? Comment { get; set; }

        [Required]
        [ReviewDateInRange("Year", "Quarter")]
        [Display(Name = "Review date")]
        public DateTime? ReviewDate { get; set; }
        public bool? IsRead { get; set; }
    }
}
