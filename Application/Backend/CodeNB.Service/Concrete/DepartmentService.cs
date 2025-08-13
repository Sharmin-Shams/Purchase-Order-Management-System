using CodeNB.Model;
using CodeNB.Repository;
using CodeNB.Types;
using static CodeNB.Model.Constants;


namespace CodeNB.Service
{
    public class DepartmentService : IDepartmentService
    {
        private readonly IDepartmentRepository repo;
        public DepartmentService(IDepartmentRepository repo)
        {
            this.repo = repo;
        }
        public async Task<Department> Create(Department department)
        {
            if (await IsValid(department))
                return await repo.Create(department);

            return department;
        }

        public async Task<List<DepartmentDto>> GetAll()
        {
            return await repo.GetAll();
        }

        public async Task<List<Department>> GetAllWithDetails()
        {
            return await repo.GetAllWithDetails();
        }

        public async Task<Department?> Update(Department department)
        {
            department.Errors.Clear();

            var departments = await GetAllWithDetails();
            var matchDept = departments.FirstOrDefault(d => d.ID == department.ID);

            if (matchDept is null)
            {
                department.Errors.Add(new("The department your trying to update cannot be found."!, ErrorType.Business, "404"));
                return department;
            };

            foreach (var e in department.Validate())
                department.Errors.Add(new(e.ErrorMessage!, ErrorType.Model, e.MemberNames.FirstOrDefault() ?? ""));

            var origInvocationDate = matchDept?.InvocationDate;
            if (origInvocationDate != department.InvocationDate && !IsValidInvocationDate(department))
                department.Errors.Add(new(string.Format(DATE_NOT_PAST_ERROR, department.GetDisplayName(nameof(Department.InvocationDate))),
                      ErrorType.Model, nameof(Department.InvocationDate)));

            if (departments.Any(d => d.ID != department.ID && d.Name.IsEqualTo(department.Name)))
                department.Errors.Add(new(string.Format(RECORD_EXISTS, $"{department.GetDisplayName(nameof(Department.Name))}"),
                    ErrorType.Business, nameof(Department.Name))
                );

            return department.Errors.Count > 0 ? department : await repo.Update(department);
        }
        public async Task<bool> Delete(Department department)
        {
            if (!await CanDeleteDepartment(department.ID))
            {
                department.AddError(new("Cannot delete department with employees.", 
                    ErrorType.Business, nameof(Department.ID)));
                return false;
            }

            var dept = (await GetAllWithDetails()).FirstOrDefault(d => d.ID == department.ID);
            if (dept is null)
            {
                department.AddError(new("Cannot find department.", ErrorType.Business, 
                    nameof(Department.ID)));
                return false;
            }

            return await repo.Delete(department);
        }

        private async Task<bool> IsValid(Department department)
        {
            department.Errors.Clear();

            foreach (var e in department.Validate())
                department.Errors.Add(new(e.ErrorMessage!, ErrorType.Model, e.MemberNames.FirstOrDefault() ?? ""));

            if (!IsValidInvocationDate(department))
                department.Errors.Add(new(string.Format(DATE_NOT_PAST_ERROR, department.GetDisplayName(nameof(Department.InvocationDate))),
                    ErrorType.Model, nameof(Department.InvocationDate)));

            var departments = await GetAll();
            if (!string.IsNullOrWhiteSpace(department?.Name) &&
                departments.Count > 0 &&
                departments.FirstOrDefault(d => d.Id != department?.ID && d.Name.IsEqualTo(department?.Name)) != null)
            {
                department?.Errors.Add(new(string.Format(RECORD_EXISTS,
                        $"{department.GetDisplayName(nameof(Department.Name))}"),
                        ErrorType.Business, nameof(Department.Name))
                );

            }

            return department?.Errors.Count == 0;
        }

        private static bool IsValidInvocationDate(Department department)
        {
            return department.InvocationDate?.Date >= DateTime.Today;
        }

        private async Task<bool> CanDeleteDepartment(int id)
        {
            return await repo.ValidateDepartmentHasEmployees(id);
        }

    }
}
