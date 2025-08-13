using CodeNB.Model;
using CodeNB.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace CodeNB.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
   [Authorize]
    public class DashboardController : ControllerBase
    {
        private readonly IDashboardService _dashboardService;

        public DashboardController(IDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }


        

        [HttpGet]
        public async Task<ActionResult<DashboardDto>> GetEmployeeDashboard()
        {

            try
            {
                var employeeIdClaim = User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (!int.TryParse(employeeIdClaim, out int employeeId))
                {
                    throw new UnauthorizedAccessException("Unable to retrieve authenticated employee ID.");
                }


                var result = await _dashboardService.GetEmployeeDashboard(employeeId);

                return Ok(result);
            }
            catch (Exception ex)
            {



                return StatusCode(500, new { message = "Internal error: " + ex.Message });
            }

           
        }
        [Authorize(Roles = $"{nameof(UserRole.RegularSupervisor)},{nameof(UserRole.HRSupervisor)}")]
        [HttpGet("dashboard-supervisor")]
        public async Task<ActionResult<DashboardDto>> GetSupervisorDashboard()
        {

            try
            {
                var employeeIdClaim = User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (!int.TryParse(employeeIdClaim, out int employeeId))
                {
                    throw new UnauthorizedAccessException("Unable to retrieve authenticated employee ID.");
                }
          
                var result = await _dashboardService.GetSupervisorDashboard(employeeId);

                return Ok(result);
            }
            catch (Exception ex)
            {



                return StatusCode(500, new { message = "Internal error: " + ex.Message });
            }


        }

    }
}
