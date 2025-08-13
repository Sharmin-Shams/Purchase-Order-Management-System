using CodeNB.Model;
using CodeNB.Repository;
using CodeNB.Types;
using System.Data;
using static CodeNB.Model.Constants;

namespace CodeNB.Service
{
    public class EmployeeService : IEmployeeService
    {
        private readonly IEmployeeRepository repo;
        private readonly IJobRepository jobRepo;
        public EmployeeService(IEmployeeRepository repo, IJobRepository jobRepo)
        {
            this.repo = repo;
            this.jobRepo = jobRepo;
        }
        public async Task<Employee> Create(Employee employee)
        {
            if (await IsValid(employee))
            {
                //Business rules after model errors are fixed
                if (!await repo.ValidateSINUnique(new string(employee.SIN?.Where(char.IsDigit).ToArray())))
                    employee.Errors.Add(new(string.Format(RECORD_EXISTS,
                        employee.GetDisplayName(nameof(Employee.SIN))), ErrorType.Business, nameof(Employee.SIN)));

                if (employee.SupervisorID.HasValue && !await IsEmployeeCEO(employee.JobID))
                {
                    if (!await CanAssignMoreEmployeesToSupervisor(employee.SupervisorID.Value))
                        employee.Errors.Add(new(SUPERVISOR_EMPLOYEES_LIMIT_ERROR, ErrorType.Business, nameof(Employee.SupervisorID)));
                }

                if (employee.Errors.Count == 0)
                {
                    var salt = PasswordUtilityService.GenerateSalt();

                    if (salt is null || salt.Length == 0)
                        throw new InvalidOperationException(nameof(Create));

                    employee.PasswordSalt = salt;
                    employee.Password = PasswordUtilityService.HashToSHA256(employee.Password!, employee.PasswordSalt);
                    employee.SIN = new string(employee.SIN?.Where(char.IsDigit).ToArray());
                    employee.Status = EmployeeStatus.ACTIVE.ToString();

                    return await repo.Create(employee);
                }
            }

            return employee;
        }

        public async Task<List<EmployeeSearchResultDto>> Search(EmployeeSearchDto searchDto)
        {
            //null employeeId can still search
            if (!string.IsNullOrWhiteSpace(searchDto.EmployeeID) && (!int.TryParse(searchDto.EmployeeID, out _) || searchDto.EmployeeID.Trim().Length != EMPLOYEE_ID_LENGTH))
                return [];

            return await repo.Search(searchDto);
        }

        public async Task<List<Job>> GetAllJobs()
        {
            return await jobRepo.GetAllJobs();
        }

        public async Task<List<EmployeeDto>> GetAllSupervisors(int? departmentId)
        {
            return await repo.GetAllSupervisors(departmentId);
        }

        public async Task<EmployeeAssignmentResultDto?> GetEmployeeAssignment(int employeeId)
        {
            return await repo.GetEmployeeAssignment(employeeId);
        }
        public async Task<EmployeeDetailsResultDto?> GetDetails(string employeeId)
        {
            //employeeId cannot be null
            if (string.IsNullOrWhiteSpace(employeeId) || !int.TryParse(employeeId, out int id) || employeeId.Trim().Length != EMPLOYEE_ID_LENGTH)
                return null;

            return await repo.GetDetails(id);
        }

        public async Task<List<EmployeeDetailsResultDto>> Search(string? employeeId, string? lastName)
        {
            //null employeeId can still search
            if (!string.IsNullOrWhiteSpace(employeeId) && (!int.TryParse(employeeId, out _) || employeeId.Trim().Length != EMPLOYEE_ID_LENGTH))
                return [];

            return await repo.Search(employeeId, lastName);

        }

        public async Task<Employee?> GetEmployee(int employeeId)
        {
            //employeeId cannot be null
            //if (string.IsNullOrWhiteSpace(employeeId) || !int.TryParse(employeeId, out int id) || employeeId.Trim().Length != EMPLOYEE_ID_LENGTH)
            //    return null;
            var emp = await repo.GetEmployee(employeeId);
            if (emp != null) emp.PasswordSalt = null;
            return emp;
        }

        public async Task<Employee?> Update(Employee employee)
        {
            if (await IsValid(employee) && await IsValidEmployeeUpdate(employee))
            {
                var empSIN = new string(employee.SIN?.Where(char.IsDigit).ToArray());
                var isEmployeeCeo = await IsEmployeeCEO(employee.JobID);

                if (!await repo.ValidateSINUnique(empSIN, employee.ID))
                    employee.Errors.Add(new(string.Format(RECORD_EXISTS,
                        employee.GetDisplayName(nameof(Employee.SIN))), ErrorType.Business, nameof(Employee.SIN)));


                if (employee.SupervisorID.HasValue && !isEmployeeCeo && EmployeeStatus.ACTIVE.IsEqualTo(employee.Status))
                {
                    if (!await CanAssignMoreEmployeesToSupervisor(employee.SupervisorID.Value, employee.ID))
                        employee.Errors.Add(new(SUPERVISOR_EMPLOYEES_LIMIT_ERROR, ErrorType.Business, nameof(Employee.SupervisorID)));
                }

                if (employee.Errors.Count == 0)
                {
                    //do not rehash if orig pass is same with current pass
                    var emp = await repo.GetEmployee(employee.ID);
                    if (!employee.Password.IsEqualTo(emp?.Password))
                    {
                        var salt = PasswordUtilityService.GenerateSalt();
                        if (salt is null || salt.Length == 0)
                            throw new InvalidOperationException(nameof(Update));

                        employee.PasswordSalt = salt;
                        employee.Password = PasswordUtilityService.HashToSHA256(employee.Password!, employee.PasswordSalt);
                    }
                    else
                    {
                        employee.PasswordSalt = emp?.PasswordSalt;
                    }

                    employee.SIN = empSIN;

                    if (isEmployeeCeo)
                    {
                        employee.SupervisorID = null;
                        employee.DepartmentID = null;
                    }


                    if (EmployeeStatus.ACTIVE.IsEqualTo(employee.Status) ||
                        EmployeeStatus.RETIRED.IsEqualTo(employee.Status))
                        employee.TerminationDate = null;

                    return await repo.Update(employee);
                }
            }

            return employee;
        }

        public async Task<PersonalInfoDto?> GetPersonalInfo(int employeeId)
        {
            //employeeId cannot be null
            //if (string.IsNullOrWhiteSpace(employeeId) || !int.TryParse(employeeId, out int id) || employeeId.Trim().Length != EMPLOYEE_ID_LENGTH)
            //    return null;

            return await repo.GetPersonalInfo(employeeId);
        }

        public async Task<PersonalInfoDto?> UpdatePersonalInfo(PersonalInfoDto info)
        {
            if (await IsValidPersonalInfoUpdate(info))
            {
                //do not rehash if orig pass is same with current pass
                var emp = await repo.GetEmployee(info.ID);
                if (!info.Password.IsEqualTo(emp?.Password))
                {
                    var salt = PasswordUtilityService.GenerateSalt();

                    if (salt is null || salt.Length == 0)
                        throw new InvalidOperationException(nameof(UpdatePersonalInfo));

                    info.PasswordSalt = salt;
                    info.Password = PasswordUtilityService.HashToSHA256(info.Password!, info.PasswordSalt);
                }
                else
                {
                    info.PasswordSalt = emp?.PasswordSalt;
                }

                return await repo.UpdatePersonalInfo(info);
            }

            return info;
        }

        public async Task<bool?> CanReinstateEmployee(Employee employee)
        {
            var emp = await GetEmployee(employee!.ID);

            if (emp is null) return null;

            var origStatus = emp.Status?.Trim();
            if (string.Equals(EmployeeStatus.RETIRED.ToString(), origStatus) && origStatus != employee.Status?.Trim())
                return false;

            return true;
        }

        private async Task<bool> IsValid(Employee employee)
        {
            employee.Errors.Clear();

            var emp = await repo.GetEmployee(employee.ID);
            foreach (var e in employee.Validate())
            {
                var hasPasswordError = e.MemberNames.Contains(nameof(Employee.Password)) &&
                       e.ErrorMessage == string.Format(PASSWORD_FORMAT_ERROR, nameof(Employee.Password));

                if (emp != null && hasPasswordError && emp.Password.IsEqualTo(employee.Password))
                    continue;

                employee.Errors.Add(new(e.ErrorMessage!, ErrorType.Model, e.MemberNames.FirstOrDefault() ?? ""));
            }


            if (!await IsEmployeeCEO(employee.JobID))
            {
                //regular, supervisor
                if (employee.JobID.HasValue && !employee.DepartmentID.HasValue)
                    employee.Errors.Add(new(string.Format(REQUIRED_SELECTION_ERROR,
                        employee.GetDisplayName(nameof(Employee.DepartmentID))), ErrorType.Model, nameof(Employee.DepartmentID)));

                if (employee.JobID.HasValue && !employee.SupervisorID.HasValue)
                    employee.Errors.Add(new(string.Format(REQUIRED_SELECTION_ERROR,
                        employee.GetDisplayName(nameof(Employee.SupervisorID))), ErrorType.Model, nameof(Employee.SupervisorID)));

                if (employee.SupervisorID.HasValue && employee.DepartmentID.HasValue)
                {
                    bool isSupervisor = employee.IsSupervisor ?? false;
                    if (isSupervisor)
                    {
                        //validate that the selected SV is an SV CEO
                        if (!await IsSupervisorCEO(employee.SupervisorID.Value))
                            employee.Errors.Add(new(string.Format(REQUIRED_CEO_SUPERVISOR_ERROR,
                                employee.GetDisplayName(nameof(Employee.SupervisorID))), ErrorType.Model, nameof(Employee.SupervisorID)));
                    }
                    else
                    {
                        var selectedSVIsALegitSv = (await repo.GetEmployee(employee.SupervisorID.Value))?.IsSupervisor ?? false;

                        //handle for same id and supervisorId
                        if (employee.SupervisorID.Value == employee.ID || !selectedSVIsALegitSv)
                            employee.Errors.Add(new(INVALID_SUPERVISOR_ERROR, ErrorType.Business, nameof(Employee.SupervisorID)));

                        else if (!await IsValidSupervisorForDepartment(employee.SupervisorID.Value, employee.DepartmentID.Value))
                            employee.Errors.Add(new(SUPERVISOR_DEPARTMENT_MISMATCH_ERROR, ErrorType.Model, nameof(Employee.SupervisorID)));
                    }
                }
            }

            return employee.Errors.Count == 0;
        }
        private async Task<bool> IsValidSupervisorForDepartment(int supervisorId, int departmentId)
        {
            return await repo.ValidateSupervisorWithinDepartment(supervisorId, departmentId);
        }

        private async Task<bool> IsSupervisorCEO(int supervisorId)
        {
            //must be a CEO that is a Supervisor
            var job = await repo.GetEmployeeJob(supervisorId);
            var isAnSvCEO = (await repo.GetEmployee(supervisorId))?.IsSupervisor ?? false;

            return job != null && job.Name?.ToUpper() == "CEO" && isAnSvCEO;
        }

        private async Task<bool> CanAssignMoreEmployeesToSupervisor(int supervisorId, int? employeeId = null)
        {
            return await repo.ActiveEmployeeCountPerSupervisor(supervisorId, employeeId) < SUPERVISOR_EMPLOYEES_LIMIT;
        }

        private async Task<bool> IsEmployeeCEO(int? jobId)
        {
            var empJob = (await GetAllJobs()).FirstOrDefault(j => j.ID == jobId);
            return empJob != null && empJob?.Name?.ToUpper() == "CEO";
        }

        private async Task<bool> IsValidEmployeeUpdate(Employee employee)
        {
            if (!string.IsNullOrWhiteSpace(employee.Status))
            {
                if (!employee.TerminationDate.HasValue && EmployeeStatus.TERMINATED.IsEqualTo(employee.Status))
                {
                    employee.Errors.Add(new(string.Format(REQUIRED_ERROR, employee
                        .GetDisplayName(nameof(Employee.TerminationDate))), ErrorType.Model, nameof(Employee.TerminationDate)));
                }

                if (EmployeeStatus.RETIRED.IsEqualTo(employee.Status))
                {
                    if (!employee.RetirementDate.HasValue)
                    {
                        employee.Errors.Add(new(string.Format(REQUIRED_ERROR, employee
                            .GetDisplayName(nameof(Employee.RetirementDate))), ErrorType.Model, nameof(Employee.RetirementDate)));
                    }
                    else
                    {
                        var origStatus = (await GetEmployee(employee.ID))?.Status;

                        var date = employee.RetirementDate.Value.Date;
                        int age = date.Year - employee.DoB.Year;
                        if (employee.DoB > date.AddYears(-age)) age--;

                        if (age < VALID_RETIREMENT_AGE)
                        {
                            employee.Errors.Add(new(string.Format(RETIREMENT_AGE_ERROR, VALID_RETIREMENT_AGE),
                                ErrorType.Model, EmployeeStatus.RETIRED.IsEqualTo(origStatus)
                                ? nameof(Employee.DoB)
                                : nameof(Employee.RetirementDate)));
                        }
                    }
                }
            }
            else
            {
                employee.Errors.Add(new(string.Format(REQUIRED_ERROR, employee
                       .GetDisplayName(nameof(Employee.Status))), ErrorType.Model, nameof(Employee.Status)));
            }

            return employee.Errors.Count == 0;
        }

        private async Task<bool> IsValidPersonalInfoUpdate(PersonalInfoDto info)
        {
            info.Errors.Clear();

            var origPassword = (await repo.GetEmployee(info.ID))?.Password;

            foreach (var e in info.Validate())
            {
                var hasPasswordError = e.MemberNames.Contains(nameof(PersonalInfoDto.Password)) &&
                          e.ErrorMessage == string.Format(PASSWORD_FORMAT_ERROR, nameof(PersonalInfoDto.Password));

                if (hasPasswordError && info.Password.IsEqualTo(origPassword))
                    continue;

                info.Errors.Add(new(e.ErrorMessage!, ErrorType.Model, e.MemberNames.FirstOrDefault() ?? ""));
            }

            return info.Errors.Count == 0;
        }
    }
}
