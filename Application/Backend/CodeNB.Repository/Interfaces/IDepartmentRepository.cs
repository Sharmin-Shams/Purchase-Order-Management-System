using CodeNB.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Repository
{
    public interface IDepartmentRepository
    {
        Task<Department> Create(Department department);
        Task<bool> Delete(Department d);
        Task<List<DepartmentDto>> GetAll();
        Task<List<Department>> GetAllWithDetails();
        Task<Department?> Update(Department department);
        Task<bool> ValidateDepartmentHasEmployees(int id);
    }
}
