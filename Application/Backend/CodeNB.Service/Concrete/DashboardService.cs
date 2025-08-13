using CodeNB.Model;
using CodeNB.Repository;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Service
{
    public class DashboardService : IDashboardService
    {
        private readonly IDashboardRepository _repository;

        public DashboardService(IDashboardRepository repository)
        {
            _repository = repository;
        }
        public async Task<DashboardDto> GetEmployeeDashboard(int employeeId)
        {
            var monthlyExpensesTask = await _repository.GetEmployeeMonthlyExpenses(employeeId);
            var unreadReviewCount =await _repository.EmployeeGetUnreadReviewCount(employeeId);

            



            var dashboard = new DashboardDto
            {
                MonthlyExpense =  monthlyExpensesTask,
               
                UnreadReviewCount =  unreadReviewCount == 0 ? null :  unreadReviewCount

            };

            return dashboard;
        }
        public async Task<DashboardDto> GetSupervisorDashboard(int employeeId)
        {
            var monthlyExpensesTask = await _repository.GetSupervisorMonthlyExpenses(employeeId);
            var unreadReviewCount = await _repository.SupervisorGetUnreadReviewCount(employeeId);

            var pendingPOCount = await _repository.GetPendingPOCount(employeeId);
             var pendingsReviewToCreateCount = await _repository.GetPendingReviewToCreateCount(employeeId);
            var totalSupervisedEmployees = await _repository.GetTotalSupervisedEmployees(employeeId);

         


            var dashboard = new DashboardDto
            {
                MonthlyExpense = monthlyExpensesTask,
                PendingPOCount = pendingPOCount == 0 ? null : pendingPOCount,
                UnreadReviewCount = unreadReviewCount == 0 ? null : unreadReviewCount,
                PendingsReviewsToCreateCount = pendingsReviewToCreateCount == 0 ? null : pendingsReviewToCreateCount,
                TotalSupervisedEmployees = totalSupervisedEmployees == 0 ? null : totalSupervisedEmployees,

            };

            return dashboard;
        }



    }
}
