using CodeNB.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Repository
{
    public interface IEmployeeRepository
    {
        Task<Employee> Create(Employee employee);
        Task<List<EmployeeSearchResultDto>> Search(EmployeeSearchDto searchDto);
        Task<List<EmployeeDto>> GetAllSupervisors(int? departmentId);
        Task<EmployeeAssignmentResultDto?> GetEmployeeAssignment(int employeeId);
        Task<bool> ValidateSINUnique(string sin, int? employeeId = null);
        Task<int> ActiveEmployeeCountPerSupervisor(int supervisorId, int? employeeId);
        Task<bool> ValidateSupervisorWithinDepartment(int supervisorId, int departmentId);
        Task<Job> GetEmployeeJob(int employeeId);
        Task<EmployeeDetailsResultDto?> GetDetails(int employeeId);
        Task<List<EmployeeDetailsResultDto>> Search(string? employeeId, string? lastName);
        Task<Employee?> GetEmployee(int employeeId);
        Task<Employee?> Update(Employee employee);
        Task<PersonalInfoDto?> GetPersonalInfo(int employeeId);
        Task<PersonalInfoDto?> UpdatePersonalInfo(PersonalInfoDto info);
        Task<List<EmployeeDetailsResultDto>> GetAllEmployees(int? departmentId);
    }
}
