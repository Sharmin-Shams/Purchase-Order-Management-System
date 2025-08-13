using CodeNB.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Service
{
    public interface IEmployeeService
    {
        Task<Employee> Create(Employee employee);
        Task<List<EmployeeSearchResultDto>> Search(EmployeeSearchDto searchDto);
        Task<List<EmployeeDto>> GetAllSupervisors(int? departmentId);
        Task<List<Job>> GetAllJobs();
        Task<EmployeeAssignmentResultDto?> GetEmployeeAssignment(int employeeId);
        Task<EmployeeDetailsResultDto?> GetDetails(string employeeId);
        Task<List<EmployeeDetailsResultDto>> Search(string? employeeId, string? lastName);
        Task<Employee?> GetEmployee(int employeeId);
        Task<Employee?> Update(Employee employee);
        Task<PersonalInfoDto?> GetPersonalInfo(int employeeId);
        Task<PersonalInfoDto?> UpdatePersonalInfo(PersonalInfoDto info);
        Task<bool?> CanReinstateEmployee(Employee employee);
    }
}
