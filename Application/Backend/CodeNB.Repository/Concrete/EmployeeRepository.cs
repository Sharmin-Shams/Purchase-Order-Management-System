using CodeNB.Model;
using CodeNB.Types;
using DAL;
using System.Data;

namespace CodeNB.Repository
{
    public class EmployeeRepository : IEmployeeRepository
    {
        private readonly IDataAccess _db;
        public EmployeeRepository(IDataAccess db) => _db = db;

        public async Task<Employee> Create(Employee e)
        {
            var parms = BuildEmployeeParams(e);
            parms.Add(new("@ID", SqlDbType.Int, e.ID, direction: ParameterDirection.Output));
            parms.Add(new("@RowVer", SqlDbType.Binary, e.RowVersion, 8, direction: ParameterDirection.Output));

            if (await _db.ExecuteNonQueryAsync("spInsertEmployee", parms) <= 0)
                throw new DataException("There was an issue adding the record to the database.");

            e.ID = ((int?)parms.FirstOrDefault(p => p.Name == "@ID")?.Value) ?? 0;

            var rowVersion = parms.FirstOrDefault(p => p.Name == "@RowVer")?.Value as byte[];
            e.RowVersion = rowVersion != null ? Convert.ToBase64String(rowVersion) : null;

            return e;
        }

        public async Task<List<EmployeeSearchResultDto>> Search(EmployeeSearchDto e)
        {
            List<Parm> parms = new() {
                new("@DepartmentID", SqlDbType.Int, e.DepartmentID),
                new("@EmployeeID", SqlDbType.Int, string.IsNullOrWhiteSpace(e.EmployeeID) ? DBNull.Value : Convert.ToInt32(e.EmployeeID)),
                new("@LastName", SqlDbType.NVarChar, e.LastName, 50)
            };

            DataTable dt = await _db.ExecuteAsync("spFilterEmployees", parms);

            return [.. dt
                .AsEnumerable()
                .Select(row => new EmployeeSearchResultDto(
                    Convert.ToInt32(row["ID"]),
                    row["LastName"].ToString()!,
                    row["FirstName"].ToString()!,
                    row["WorkPhone"].ToString()!,
                    row["OfficeLocation"].ToString()!,
                    row["Position"].ToString()!
                ))];
        }

        public async Task<List<EmployeeDto>> GetAllSupervisors(int? departmentId)
        {
            DataTable dt = await _db.ExecuteAsync("spGetAllSupervisors");

            return [.. dt
                .AsEnumerable()
                .Select(row => new EmployeeDto(
                    (int)row["ID"],
                    row["FirstName"].ToString()!,
                    row["LastName"].ToString()!,
                    row["MiddleInitial"] == DBNull.Value ? null : Convert.ToChar(row["MiddleInitial"])
                ))];
        }

        public async Task<EmployeeAssignmentResultDto?> GetEmployeeAssignment(int employeeId)
        {
            DataTable dt = await _db.ExecuteAsync("spGetEmployeeAssignment", [new("@ID", SqlDbType.Int, employeeId)]);

            if (dt.Rows.Count == 0)
                return null;

            DataRow row = dt.Rows[0];

            return new EmployeeAssignmentResultDto
            {
                EmployeeName = row["EmployeeName"].ToString(),
                DepartmentName = row["DepartmentName"].ToString(),
                SupervisorName = row["SupervisorName"].ToString()
            };
        }

        public async Task<bool> ValidateSINUnique(string sin, int? employeeId = null)
        {
            List<Parm> parms = [
                new("@SIN", SqlDbType.NVarChar, sin, 11),
                new("@ID", SqlDbType.Int, !employeeId.HasValue ? DBNull.Value : employeeId)
           ];

            return Convert.ToBoolean(
                await _db.ExecuteScalarAsync("spValidateSINUnique", parms)
            );
        }

        public async Task<int> ActiveEmployeeCountPerSupervisor(int supervisorId, int? employeeId)
        {
            List<Parm> parms = [new("@SupervisorID", SqlDbType.Int, supervisorId)];

            if (employeeId.HasValue)
                parms.Add(new("@ID", SqlDbType.Int, employeeId));

            return Convert.ToInt32(
                await _db.ExecuteScalarAsync("spCountEmployeesBySupervisor", parms)
            );
        }

        public async Task<bool> ValidateSupervisorWithinDepartment(int supervisorId, int departmentId)
        {
            List<Parm> parms = [
                new("@SupervisorID", SqlDbType.Int, supervisorId),
                new("@DepartmentID", SqlDbType.Int, departmentId)
            ];

            return Convert.ToBoolean(await _db.ExecuteScalarAsync("spValidateSupervisorWithinDepartment", parms));
        }

        public async Task<Job> GetEmployeeJob(int employeeId)
        {
            DataTable dt = await _db.ExecuteAsync("spGetJobByEmployeeId", [new("@ID", SqlDbType.Int, employeeId)]);

            if (dt.Rows.Count == 0)
                throw new NoNullAllowedException(nameof(GetEmployeeJob));

            DataRow row = dt.Rows[0];

            return new Job
            {
                ID = Convert.ToInt32(row["ID"]),
                Name = row["Name"].ToString()
            };
        }

        public async Task<EmployeeDetailsResultDto?> GetDetails(int employeeId)
        {
            DataTable dt = await _db.ExecuteAsync("spGetEmployeeDetails", [new("@EmployeeID", SqlDbType.Int, employeeId)]);

            if (dt.Rows.Count == 0)
                return null;

            DataRow row = dt.Rows[0];

            return PopulateEmployeeDetailsResultDto(row);
        }

        public async Task<List<EmployeeDetailsResultDto>> Search(string? employeeId, string? lastName)
        {
            List<Parm> parms = [
                new("@EmployeeID", SqlDbType.Int, string.IsNullOrWhiteSpace(employeeId) ? DBNull.Value : Convert.ToInt32(employeeId)),
                new("@LastName", SqlDbType.NVarChar, lastName?.Trim(), 50)
            ];

            DataTable dt = await _db.ExecuteAsync("spSearchEmployees", parms);

            return [.. dt
                .AsEnumerable()
                .Select(row => PopulateEmployeeDetailsResultDto(row))
            ];
        }

        public async Task<Employee?> GetEmployee(int employeeId)
        {
            List<Parm> parms = [
                new("@ID", SqlDbType.Int, employeeId)
            ];

            DataTable dt = await _db.ExecuteAsync("spGetEmployeeById", parms);

            if (dt.Rows.Count == 0)
                return null;

            return PopulateEmployee(dt.Rows[0]);
        }

        public async Task<Employee?> Update(Employee e)
        {
            var parms = BuildEmployeeParams(e);

            var rowVersionBytes = Convert.FromBase64String(e.RowVersion!) ?? null;

            parms.AddRange([
                new("@ID", SqlDbType.Int, e.ID),
                new("@TerminationDate", SqlDbType.Date, e.TerminationDate ?? (object?)DBNull.Value),
                new("@RetirementDate", SqlDbType.Date, e.RetirementDate ?? (object)DBNull.Value),
                new("@RowVer", SqlDbType.Binary, rowVersionBytes ?? (object)DBNull.Value, 8)
            ]);

            if (await _db.ExecuteNonQueryAsync("spUpdateEmployee", parms) <= 0)
                return null;

            return e;
        }

        public async Task<PersonalInfoDto?> GetPersonalInfo(int employeeId)
        {
            var emp = await GetEmployee(employeeId);

            if (emp is null)
                return null;

            return new PersonalInfoDto
            {
                ID = emp.ID,
                FirstName = emp.FirstName,
                MiddleInitial = emp.MiddleInitial,
                LastName = emp.LastName,
                StreetAddress = emp.StreetAddress,
                City = emp.City,
                PostalCode = emp.PostalCode,
                Password = emp.Password,
                PasswordSalt = emp.PasswordSalt,
                RowVersion = emp.RowVersion
            };
        }

        public async Task<PersonalInfoDto?> UpdatePersonalInfo(PersonalInfoDto i)
        {
            var rowVersionBytes = Convert.FromBase64String(i.RowVersion!) ?? null;

            List<Parm> parms = [
                new("@ID", SqlDbType.Int, i.ID),
                new("@FirstName", SqlDbType.NVarChar, i.FirstName!.Trim(), 50),
                new("@LastName", SqlDbType.NVarChar, i.LastName!.Trim(), 50),
                new("@MiddleInitial", SqlDbType.NChar, i.MiddleInitial ?? (object)DBNull.Value, 1),
                new("@StreetAddress", SqlDbType.NVarChar, i.StreetAddress?.Trim(), 255),
                new("@City", SqlDbType.NVarChar, i.City?.Trim(), 255),
                new("@PostalCode", SqlDbType.NVarChar, i.PostalCode?.Trim(), 7),
                new("@PasswordHash", SqlDbType.NVarChar, i.Password, 64),
                new("@PasswordSalt", SqlDbType.Binary, i.PasswordSalt, 16),
                new("@RowVer", SqlDbType.Binary, rowVersionBytes ?? (object)DBNull.Value, 8)
            ];

            if (await _db.ExecuteNonQueryAsync("spUpdatePersonalInfo", parms) <= 0)
                return null;

            return i;
        }

        public async Task<List<EmployeeDetailsResultDto>> GetAllEmployees(int? departmentId)
        {
            List<Parm> parms = [new("@DepartmentID", SqlDbType.Int, departmentId.HasValue ?
                departmentId.Value : DBNull.Value)];
            DataTable dt = await _db.ExecuteAsync("spGetAllEmployees");


            return [.. dt
                .AsEnumerable()
                .Select(row => PopulateEmployeeDetailsResultDto(row))
            ];
        }

        private static EmployeeDetailsResultDto PopulateEmployeeDetailsResultDto(DataRow row)
        {
            return new EmployeeDetailsResultDto(
                    Convert.ToInt32(row["ID"]),
                    row["FirstName"].ToString()!,
                    row.IsNull("MiddleInitial") ? null : row["MiddleInitial"].ToString(),
                    row["LastName"].ToString()!,
                    row["MailingAddress"].ToString()!,
                    row["WorkPhone"].ToString()!,
                    row["CellPhone"].ToString()!,
                    row["Email"].ToString()!
            );
        }

        private static Employee PopulateEmployee(DataRow row)
        {
            return new Employee
            {
                ID = (int)row["ID"],
                FirstName = row["FirstName"].ToString(),
                LastName = row["LastName"].ToString(),
                MiddleInitial = row["MiddleInitial"] == DBNull.Value ? null : Convert.ToChar(row["MiddleInitial"]),
                StreetAddress = row["StreetAddress"].ToString(),
                City = row["City"].ToString(),
                PostalCode = row["PostalCode"].ToString(),
                DoB = (DateTime)row["DOB"],
                SIN = row["SIN"].ToString(),
                SeniorityDate = (DateTime)row["SeniorityDate"],
                JobStartDate = (DateTime)row["JobStartDate"],
                WorkPhone = row["WorkPhone"].ToString(),
                CellPhone = row["CellPhone"].ToString(),
                Email = row["Email"].ToString(),
                IsSupervisor = row["IsSupervisor"] == DBNull.Value ? null : (bool)row["IsSupervisor"],
                OfficeLocation = row["OfficeLocation"].ToString(),
                Status = row["Status"].ToString(),
                JobID = (int)row["JobID"],
                SupervisorID = row["SupervisorID"] != DBNull.Value ? (int)row["SupervisorID"] : null,
                DepartmentID = row["DepartmentID"] != DBNull.Value ? (int)row["DepartmentID"] : null,
                Password = row["PasswordHash"].ToString(),
                PasswordSalt = row.Table.Columns.Contains("PasswordSalt") && row["PasswordSalt"] != DBNull.Value ?
                    (byte[])row["PasswordSalt"] : null,
                RetirementDate = row["RetirementDate"] != DBNull.Value ? (DateTime)row["RetirementDate"] : null,
                TerminationDate = row["TerminationDate"] != DBNull.Value ? (DateTime)row["TerminationDate"] : null,
                RowVersion = row["RowVer"] != DBNull.Value ? Convert.ToBase64String((byte[])row["RowVer"]) : null
            };
        }

        private static List<Parm> BuildEmployeeParams(Employee e)
        {
            return [
                new("@FirstName", SqlDbType.NVarChar, e.FirstName!.Trim(), 50),
                new("@LastName", SqlDbType.NVarChar, e.LastName!.Trim(), 50),
                new("@MiddleInitial", SqlDbType.NChar, e.MiddleInitial ?? (object)DBNull.Value, 1),
                new("@StreetAddress", SqlDbType.NVarChar, e.StreetAddress?.Trim(), 255),
                new("@City", SqlDbType.NVarChar, e.City?.Trim(), 255),
                new("@PostalCode", SqlDbType.NVarChar, e.PostalCode?.Trim(), 7),
                new("@DOB", SqlDbType.Date, e.DoB.Date),
                new("@SIN", SqlDbType.NVarChar, e.SIN?.Trim(), 11),
                new("@SeniorityDate", SqlDbType.Date, e.SeniorityDate),
                new("@JobStartDate", SqlDbType.Date, e.JobStartDate),
                new("@WorkPhone", SqlDbType.NVarChar, e.WorkPhone?.Trim(), 14),
                new("@CellPhone", SqlDbType.NVarChar, e.CellPhone?.Trim(), 14),
                new("@Email", SqlDbType.NVarChar, e.Email?.Trim(), 255),
                new("@JobID", SqlDbType.Int, e.JobID),
                new("@SupervisorID", SqlDbType.Int, e.SupervisorID ?? (object)DBNull.Value),
                new("@DepartmentID", SqlDbType.Int, e.DepartmentID ?? (object)DBNull.Value),
                new("@PasswordHash", SqlDbType.NVarChar, e.Password, 64),
                new("@PasswordSalt", SqlDbType.Binary, e.PasswordSalt, 16),
                new("@Status", SqlDbType.NVarChar, e.Status?.Trim().ToUpper(), 20),
                new("@OfficeLocation", SqlDbType.NVarChar, e.OfficeLocation?.Trim() ?? (object)DBNull.Value, 255),
                new("@IsSupervisor", SqlDbType.Bit, e.IsSupervisor ?? (object)DBNull.Value),
            ];
        }
    }
}
