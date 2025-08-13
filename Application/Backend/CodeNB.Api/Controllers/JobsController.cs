using CodeNB.Api.Models;
using CodeNB.Model;
using CodeNB.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace CodeNB.Api.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class JobsController : ControllerBase
    {
        private readonly IEmployeeService employeeService;
        public JobsController(IEmployeeService employeeService)
        {
            this.employeeService = employeeService;
        }

        [HttpGet]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<List<Job>>> Get()
        {
            try
            {
                return await employeeService.GetAllJobs();
            }
            catch
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new ApiMessageResponse
                {
                    Status = StatusCodes.Status500InternalServerError,
                    Message = "Something went wrong while processing your request. Please try again later."
                });
            }
        }
    }
}
