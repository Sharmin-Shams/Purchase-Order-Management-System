using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public record EmployeeDto(int Id, string FirstName, string LastName, char? MiddleInitial = null);
}
