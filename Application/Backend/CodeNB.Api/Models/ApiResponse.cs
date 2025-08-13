namespace CodeNB.Api.Models
{
    /// <summary>
    /// Represents a standard API response containing a status code, message (e.g., success or error), and optional data.
    /// </summary>
    public class ApiDataResponse<T>
    {
        public int Status { get; set; }
        public string? Message { get; set; }
        public T? Data { get; set; }
    }

    /// <summary>
    /// Represents a simple API response with only a status code and message.
    /// </summary>
    public class ApiMessageResponse
    {
        public int Status { get; set; }
        public string? Message { get; set; }
    }

    /// <summary>
    /// Represents an API error response for model validation errors, containing a status code and a list of error details.
    /// </summary>
    public class ApiErrorsResponse<T>
    {
        public int Status { get; set; }
        public List<T> Errors { get; set; } = new();
    }
}
