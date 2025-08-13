using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public class LoginResultDto
    {
        public int ID { get; set; }
        public string? LastName { get; set; }
        public string? FirstName { get; set; }
        public string? Role { get; set; }
        public string? Token { get; set; }
        public int? ExpiresIn { get; set; }
    }
}
