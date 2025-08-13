using CodeNB.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Repository
{
    public interface IDashboardRepository
    {
        Task<List<MonthlyExpenseDto>> GetEmployeeMonthlyExpenses(int employeeId);
        Task<List<MonthlyExpenseDto>> GetSupervisorMonthlyExpenses(int employeeId);
        Task <int> EmployeeGetUnreadReviewCount(int employeeId);
        Task<int> SupervisorGetUnreadReviewCount(int employeeId);


        Task<int> GetPendingPOCount(int employeeId);
       
        Task<int> GetPendingReviewToCreateCount(int employeeId);
        Task<int> GetTotalSupervisedEmployees(int employeeId);
    }
}
