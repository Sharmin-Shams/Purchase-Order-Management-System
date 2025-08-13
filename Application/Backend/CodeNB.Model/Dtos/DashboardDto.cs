using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
  public class DashboardDto
    {

        public List<MonthlyExpenseDto> MonthlyExpense { get; set; } = new();
        public int? PendingPOCount { get; set; }
        public int? UnreadReviewCount { get; set; }
        public int? PendingsReviewsToCreateCount { get; set; }
        public int? TotalSupervisedEmployees { get; set; }
    }
}
