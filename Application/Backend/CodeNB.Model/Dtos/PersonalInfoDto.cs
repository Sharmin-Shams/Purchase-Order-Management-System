using System.ComponentModel.DataAnnotations;
using static CodeNB.Model.Constants;

namespace CodeNB.Model
{
    public class PersonalInfoDto : BaseEntity
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

        [Display(Name = "Middle Initial")]
        public char? MiddleInitial { get; set; }

        [Required]
        [MinLength(3, ErrorMessage = MIN_LENGTH_ERROR)]
        [MaxLength(50, ErrorMessage = MAX_LENGTH_ERROR)]
        [Display(Name = "Last Name")]
        public string? LastName { get; set; }

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

        public string? RowVersion { get; set; }
    }
}
