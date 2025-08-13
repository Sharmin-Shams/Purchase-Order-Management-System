using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Model
{
    public abstract class BaseEntity
    {
        public List<ValidationError> Errors { get; set; } = new();

        public void AddError(ValidationError error)
        {
            Errors.Add(error);
        }
    }
}
