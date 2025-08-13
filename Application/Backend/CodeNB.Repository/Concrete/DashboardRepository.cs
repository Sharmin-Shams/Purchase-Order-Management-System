using CodeNB.Model;
using CodeNB.Types;
using DAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Repository
{
    public class DashboardRepository : IDashboardRepository
    {
        private readonly IDataAccess _db;
        public DashboardRepository(IDataAccess db)
        {
            _db = db;
        }

        public async Task<List<MonthlyExpenseDto>> GetEmployeeMonthlyExpenses(int employeeId)
        {


            List<Parm> parms = [
                new("@EmployeeID", SqlDbType.Int, employeeId)
            ];

            DataTable dt = await _db.ExecuteAsync("spGetEmployeeMonthlyExpenses", parms);

            return [.. dt.AsEnumerable().Select(row => new MonthlyExpenseDto
                    {
                        Month = row["Month"].ToString()!,
                        ExpenseTotal = Convert.ToDecimal(row["ExpenseTotal"])
                    })];

        }

        public async Task<int> EmployeeGetUnreadReviewCount(int employeeId)
        {
            List<Parm> parms = [new("@EmployeeID", SqlDbType.Int, employeeId)];



            return Convert.ToInt32(
                await _db.ExecuteScalarAsync("spGetUnreadEmployeeReviewCount", parms)
            );
        }

        public async Task<int> SupervisorGetUnreadReviewCount(int employeeId)
        {
            List<Parm> parms = [new("@EmployeeID", SqlDbType.Int, employeeId)];



            return Convert.ToInt32(
                await _db.ExecuteScalarAsync("spGetUnreadReviewCountSupervisor", parms)
            );
        }


        public async Task<List<MonthlyExpenseDto>> GetSupervisorMonthlyExpenses(int employeeId)
        {


            List<Parm> parms = [
                new("@EmployeeID", SqlDbType.Int, employeeId)
            ];

            DataTable dt = await _db.ExecuteAsync("spGetSupervisorMonthlyExpenses", parms);

            return [.. dt.AsEnumerable().Select(row => new MonthlyExpenseDto
                    {
                        Month = row["Month"].ToString()!,
                        ExpenseTotal = Convert.ToDecimal(row["ExpenseTotal"])
                    })];

        }


        public async Task<int> GetPendingPOCount(int employeeId)
        {
            List<Parm> parms = [new("@EmployeeID", SqlDbType.Int, employeeId)];



            return Convert.ToInt32(
                await _db.ExecuteScalarAsync("spGetPendingPOCount", parms)
            );
        }
    
       
        public async Task<int> GetPendingReviewToCreateCount(int employeeId)
        {
            List<Parm> parms = [new("@EmployeeID", SqlDbType.Int, employeeId)];



            return Convert.ToInt32(
                await _db.ExecuteScalarAsync("spGetPendingReviewToCreateList", parms)
            );
        }

        public async Task<int> GetTotalSupervisedEmployees(int employeeId)
        {
            List<Parm> parms = [new("@EmployeeID", SqlDbType.Int, employeeId)];



            return Convert.ToInt32(
                await _db.ExecuteScalarAsync("spGetTotalSupervisedEmployees", parms)
            );
        }
    }
}
