using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static CodeNB.Model.Constants;

namespace CodeNB.Model
{
    public class Department : BaseEntity
    {
        public int ID { get; set; }

        [Required]
        [MinLength(3, ErrorMessage = MIN_LENGTH_ERROR)]
        [MaxLength(128, ErrorMessage = MAX_LENGTH_ERROR)]
        [Display(Name = "Department name")]
        public string? Name { get; set; }

        [Required]
        [MaxLength(512, ErrorMessage = MAX_LENGTH_ERROR)]
        public string? Description { get; set; }

        [Required]
        [Display(Name = "Invocation date")]
        public DateTime? InvocationDate { get; set; }
        public string? RowVersion { get; set; }
    }
}
