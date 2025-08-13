using CodeNB.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Repository
{
    public interface IJobRepository
    {
        Task<List<Job>> GetAllJobs();
    }
}
