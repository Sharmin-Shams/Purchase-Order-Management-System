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
    public class DepartmentRepository : IDepartmentRepository
    {
        private readonly IDataAccess _db;

        public DepartmentRepository(IDataAccess db)
        {
            _db = db;
        }
        public async Task<Department> Create(Department d)
        {
            List<Parm> parms = [
                new("@ID", SqlDbType.Int, d.ID, direction: ParameterDirection.Output),
                new("@RowVer", SqlDbType.Binary, d.RowVersion, 8, direction: ParameterDirection.Output),
                new("@Name", SqlDbType.NVarChar, d.Name!.Trim(), 128),
                new("@Description", SqlDbType.NVarChar, d.Description!.Trim(), 512),
                new("@InvocationDate", SqlDbType.Date, d.InvocationDate?.Date),
            ];

            if (await _db.ExecuteNonQueryAsync("spInsertDepartment", parms) <= 0)
                throw new DataException("There was an issue adding the record to the database.");

            d.ID = (int?)parms.FirstOrDefault(p => p.Name == "@ID")!.Value ?? 0;

            var rowVersion = parms.FirstOrDefault(p => p.Name == "@RowVer")?.Value as byte[];
            d.RowVersion = rowVersion != null ? Convert.ToBase64String(rowVersion) : null;

            return d;

        }

        public async Task<List<DepartmentDto>> GetAll()
        {
            DataTable dt = await _db.ExecuteAsync("spGetAllDepartments");

            return [.. dt
                .AsEnumerable()
                .Select(row => new DepartmentDto(
                    (int)row["ID"],
                    row["Name"].ToString()!
                ))];
        }

        public async Task<List<Department>> GetAllWithDetails()
        {
            DataTable dt = await _db.ExecuteAsync("spGetAllDepartmentsWithDetails");

            return [.. dt
                .AsEnumerable()
                .Select(row => new Department
                {
                    ID =  Convert.ToInt32(row["ID"]),
                    Name = row["Name"].ToString(),
                    Description = row["Description"].ToString(),
                    InvocationDate = (DateTime)row["InvocationDate"],
                    RowVersion = row["RowVer"] != DBNull.Value ? Convert.ToBase64String((byte[])row["RowVer"]) : null
                })
            ];
        }

        public async Task<Department?> Update(Department d)
        {
            List<Parm> parms = [
                new("@ID", SqlDbType.Int, d.ID),
                new("@Name", SqlDbType.NVarChar, d.Name!.Trim(), 128),
                new("@Description", SqlDbType.NVarChar, d.Description!.Trim(), 512),
                new("@InvocationDate", SqlDbType.Date, d.InvocationDate?.Date),
                new("@RowVer", SqlDbType.Binary, ConvertBase64ToByte(d.RowVersion!) ?? (object)DBNull.Value, 8)
            ];

            if (await _db.ExecuteNonQueryAsync("spUpdateDepartment", parms) <= 0)
                return null;

            return d;
        }
        public async Task<bool> ValidateDepartmentHasEmployees(int id)
        {
            List<Parm> parms = [new("@ID", SqlDbType.Int, id)];

            return Convert.ToBoolean(
                  await _db.ExecuteScalarAsync("spCheckIfDepartmentCanBeDeleted", parms)
            );
        }

        public async Task<bool> Delete(Department d)
        {
            List<Parm> parms = [
                new("@ID", SqlDbType.Int, d.ID),
                new("@RowVer", SqlDbType.Binary, ConvertBase64ToByte(d.RowVersion!) ?? (object)DBNull.Value, 8)
            ];

            return await _db.ExecuteNonQueryAsync("spDeleteDepartment", parms) > 0;
        }

        private static byte[]? ConvertBase64ToByte(string rowVersion)
        {
            return Convert.FromBase64String(rowVersion) ?? null;
        }

    }
}
