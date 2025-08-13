using CodeNB.Model;
using DAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Repository
{
    public class JobRepository : IJobRepository
    {
        private readonly IDataAccess _db;
        public JobRepository(IDataAccess db)
        {
            _db = db;
        }

        public async Task<List<Job>> GetAllJobs()
        {
            DataTable dt = await _db.ExecuteAsync("spGetAllJobs");

            return [.. dt
                .AsEnumerable()
                .Select(row => new Job()
                {
                    ID = (int)row["ID"],
                    Name = row["Name"].ToString()!
                })];
        }
    }
}
