using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public class SupervisorItemDecisionDTO
    {

        public int ItemID { get; set; }

        public int UpdatedItemStatusID { get; set; }

        public string? DenialReason { get; set; }
    }
}
