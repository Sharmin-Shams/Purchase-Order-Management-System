using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public class EmployeeReviewDto
    {
        public int ID { get; set; }
        public int Year { get; set; }
        public int Quarter { get; set; }
        public DateTime ReviewDate { get; set; }
        public required string SupervisorName { get; set; }
        public required string Comment { get; set; }
        public required string Rating { get; set; }
        public bool IsRead { get; set; }
    }
}
