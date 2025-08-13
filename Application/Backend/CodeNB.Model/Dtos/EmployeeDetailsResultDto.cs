using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public record EmployeeDetailsResultDto(
           int Id,
           string FirstName,
           string? MiddleInitial,
           string LastName,
           string MailingAddress,
           string WorkPhone,
           string CellPhone,
           string Email
    );
}
