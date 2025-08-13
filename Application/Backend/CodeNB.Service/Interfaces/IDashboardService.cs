using CodeNB.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Service 
{
    public interface IDashboardService
    {
      Task<DashboardDto> GetEmployeeDashboard(int id);
        Task<DashboardDto> GetSupervisorDashboard(int id);

    }
}
