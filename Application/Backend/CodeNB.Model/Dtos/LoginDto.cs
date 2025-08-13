using System.ComponentModel.DataAnnotations;
using static CodeNB.Model.Constants;

namespace CodeNB.Model
{
    public class LoginDto: BaseEntity
    {
        [Required]
        public string? Username { get; set; }

        [Required]
        public string? Password { get; set; }
    }
}
