using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public record EmployeeSearchResultDto(
      int Id, 
      string LastName,
      string FirstName,
      string WorkPhone,
      string OfficeLocation,
      string Position
  );
}
