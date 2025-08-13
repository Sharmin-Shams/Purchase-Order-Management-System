using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public class EmailConfiguration
    {
        public string From { get; set; } 
        public string SmtpServer { get; set; }
        public int Port { get; set; }

    }
}
