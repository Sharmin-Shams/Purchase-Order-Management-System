namespace CodeNB.Model
{
    public static class Constants
    {
        public const decimal DEFAULT_TAX_RATE = 0.15m;
        public const int PURCHASE_ORDER_STATUSID = 1;

        public const int PURCHASE_ORDER_ITEM_STATUSID = 1;

        public const string MIN_LENGTH_ERROR = "{0} must be at least {1} characters in length.";
        public const string MAX_LENGTH_ERROR = "{0} cannot exceed {1} characters in length.";
        public const string MIN_MAX_ERROR = "{0} must be a between {2} and {1} characters in length.";

        public const string REQUIRED_ERROR = "The {0} field is required.";
        public const string REQUIRED_SELECTION_ERROR = "{0} selection is required.";
        public const string REQUIRED_CEO_SUPERVISOR_ERROR = "{0} must be a CEO.";

        public const string PASSWORD_REGEX = "^(?=.*[A-Z])(?=.*\\d)(?=.*[\\W_]).{6,}$";
        public const string POSTAL_REGEX = "^[A-Za-z]\\d[A-Za-z] ?\\d[A-Za-z]\\d$";
        public const string PHONE_REGEX = "^\\(?\\d{3}\\)?[-.\\s]?\\d{3}[-.\\s]?\\d{4}$";
        public const string SIN_REGEX = "^\\d{3}[- ]?\\d{3}[- ]?\\d{3}$";

        public const string PASSWORD_FORMAT_ERROR = "{0} must be at least 6 characters long and contain at least one uppercase letter, one number, and one special character.";
        public const string POSTAL_FORMAT_ERROR = "{0} must be in the format A1A 1A1";
        public const string PHONE_FORMAT_ERROR = "{0} must be in the format (XXX) XXX XXXX";
        public const string SIN_FORMAT_ERROR = "{0} must be in the format XXX XXX XXXX";

        public const int MINIMUM_AGE = 16;
        public const int VALID_RETIREMENT_AGE = 65;
        public const string MIN_AGE_ERROR = "Age must be {0} years old and above.";
        public const string RETIREMENT_AGE_ERROR = "Age must be at least {0} to qualify for retirement.";

        public const string DATE_NOT_PAST_ERROR = "{0} must not be in the past.";
        public const string DATE_NOT_BEFORE_SENIORITY = "{0} cannot be prior to Seniority Date.";

        public const string RECORD_EXISTS = "{0} already exists in records.";
        public const string NO_RECORDS_FOUND = "No records found.";

        public const int SUPERVISOR_EMPLOYEES_LIMIT = 10;
        public const int EMPLOYEE_ID_LENGTH = 8;

        public const string SUPERVISOR_DEPARTMENT_MISMATCH_ERROR = "The selected supervisor is not associated with the chosen department.";
        public const string SUPERVISOR_EMPLOYEES_LIMIT_ERROR = "Supervisor has reached the maximum number of assigned employees.";
        public const string INVALID_SUPERVISOR_ERROR = "Please select a valid supervisor.";
        public const string EMPLOYEE_ALREADY_RETIRED = "Employee is already retired.";
    }
}
