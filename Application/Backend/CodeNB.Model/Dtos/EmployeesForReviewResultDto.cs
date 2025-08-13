using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public class EmployeesForReviewResultDto
    {
        public int Year { get; set; }
        public int Quarter { get; set; }
        public List<EmployeeDto> Employees { get; set; } = [];
    }
}
