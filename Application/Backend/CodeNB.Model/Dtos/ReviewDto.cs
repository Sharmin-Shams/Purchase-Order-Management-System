namespace CodeNB.Model
{
    public class ReviewDto
    {
        public int Year { get; set; }
        public int Quarter { get; set; }
        public int SupervisorID { get; set; }
        public int EmployeeID { get; set; }
        public string? SupervisorName { get; set; }
        public string? SupervisorEmail { get; set; }
        public string? EmployeeFirstName { get; set; }
        public string? EmployeeLastName { get; set; }
        public bool? IsOutStanding { get; set; }
    }
}