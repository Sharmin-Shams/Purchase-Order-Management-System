using CodeNB.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Service
{
    public interface IDepartmentService
    {
        Task<Department> Create(Department department);
        Task<List<DepartmentDto>> GetAll();
        Task<List<Department>> GetAllWithDetails();
        Task<Department?>Update(Department department);
        Task<bool> Delete(Department department);
    }
}
