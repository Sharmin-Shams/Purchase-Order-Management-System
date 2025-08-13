using CodeNB.Types;

namespace CodeNB.Model
{
    public class ValidationError
    {
        public ValidationError(string desc, ErrorType type, string field = "")
        {
            Description = desc;
            ErrorType = type;
            Field = field;
        }

        public string Description { get; set; }
        public ErrorType ErrorType { get; set; }
        public string Field { get; set; }
    }
}
