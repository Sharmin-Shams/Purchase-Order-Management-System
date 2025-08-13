using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static CodeNB.Model.Constants;

namespace CodeNB.Model
{
    public class Employee : BaseEntity
    {
        public int ID { get; set; }

        public byte[]? PasswordSalt { get; set; }

        [Required]
        [RegularExpression(PASSWORD_REGEX, ErrorMessage = PASSWORD_FORMAT_ERROR)]
        public string? Password { get; set; }

        [Required]
        [MinLength(2, ErrorMessage = MIN_LENGTH_ERROR)]
        [MaxLength(50, ErrorMessage = MAX_LENGTH_ERROR)]
        [Display(Name = "First Name")]
        public string? FirstName { get; set; }

        [Required]
        [MinLength(3, ErrorMessage = MIN_LENGTH_ERROR)]
        [MaxLength(50, ErrorMessage = MAX_LENGTH_ERROR)]
        [Display(Name = "Last Name")]
        public string? LastName { get; set; }

        [Display(Name = "Middle Initial")]
        public char? MiddleInitial { get; set; }

        [Required]
        [Display(Name = "Street Address")]
        public string? StreetAddress { get; set; }

        [Required]
        [Display(Name = "City")]
        public string? City { get; set; }

        [Required]
        [RegularExpression(POSTAL_REGEX, ErrorMessage = POSTAL_FORMAT_ERROR)]
        [Display(Name = "Postal Code")]
        public string? PostalCode { get; set; }

        [Required]
        [MinimumAge]
        [Display(Name = "Date of Birth")]
        public DateTime DoB { get; set; }

        [Required]
        [RegularExpression(SIN_REGEX, ErrorMessage = SIN_FORMAT_ERROR)]
        [Display(Name = "Social Insurance Number")]
        public string? SIN { get; set; }

        [Required]
        [Display(Name = "Seniority Date")]
        public DateTime? SeniorityDate { get; set; }

        [Required]
        [JobStartDateNotBeforeSeniorityDate]
        [Display(Name = "Job Start Date")]
        public DateTime? JobStartDate { get; set; }

        [Required]
        [RegularExpression(PHONE_REGEX, ErrorMessage = PHONE_FORMAT_ERROR)]
        [Display(Name = "Work Phone")]
        public string? WorkPhone { get; set; }

        [Required]
        [RegularExpression(PHONE_REGEX, ErrorMessage = PHONE_FORMAT_ERROR)]
        [Display(Name = "Cell Phone")]
        public string? CellPhone { get; set; }

        [Required]
        [EmailAddress]
        [MaxLength(255, ErrorMessage = MAX_LENGTH_ERROR)]
        [Display(Name = "Email Address")]
        public string? Email { get; set; }

        public bool? IsSupervisor { get; set; }

        [Display(Name = "Supervisor")]
        public int? SupervisorID { get; set; }

        [Display(Name = "Department")]
        public int? DepartmentID { get; set; }

        [Required(ErrorMessage = REQUIRED_SELECTION_ERROR)]
        [Display(Name = "Job")]
        public int? JobID { get; set; }

        [Required]
        [Display(Name = "Office Location")]
        public string? OfficeLocation { get; set; }

        public string? Status { get; set; }

        [Display(Name = "Retirement Date")]
        public DateTime? RetirementDate { get; set; }

        [Display(Name = "Termination Date")]
        public DateTime? TerminationDate { get; set; }
        public string? RowVersion { get; set; }
    }
}
