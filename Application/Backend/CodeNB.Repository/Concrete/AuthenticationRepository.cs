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
    public class AuthenticationRepository : IAuthenticationRepository
    {
        private readonly IDataAccess _db;
        public AuthenticationRepository(IDataAccess dataAccess) => _db = dataAccess;

        public async Task<byte[]?> GetUserSalt(int? id)
        {
            var salt = await _db.ExecuteScalarAsync("spGetSaltByEmployeeId", [new("@ID", SqlDbType.Int, id)]);

            if (salt == null)
                return null;

            return (byte[])salt;
        }

        public async Task<LoginResultDto?> Login(LoginDto user)
        {
            DataTable dt = await _db.ExecuteAsync("spLogin", [
                new Parm("@ID", SqlDbType.Int, Convert.ToInt32(user.Username)),
                new Parm("@HashedPassword", SqlDbType.NVarChar, user.Password, 64)
            ]);

            if (dt.Rows.Count == 0)
                return null;

            DataRow row = dt.Rows[0];

            return new LoginResultDto
            {
                ID = (int)row["ID"],
                FirstName = row["FirstName"].ToString(),
                LastName = row["LastName"].ToString(),
                Role = row["Role"].ToString(),
            };
        }
    }
}
