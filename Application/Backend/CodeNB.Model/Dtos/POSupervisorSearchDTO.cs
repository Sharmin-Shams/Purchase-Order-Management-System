using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public class POSupervisorSearchDTO
    {
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string? PONumber { get; set; }
        public string? POStatus { get; set; }
        public string? EmployeeFullName { get; set; }
        public int EmployeeID { get; set; }
       // public int SupervisorID { get; set; }
      

    }
}
