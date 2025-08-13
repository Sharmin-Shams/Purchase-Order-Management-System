using CodeNB.Api.Models;
using CodeNB.Model;
using CodeNB.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace CodeNB.Api.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class EmployeesController : ControllerBase
    {
        private readonly IEmployeeService employeeService;
        public EmployeesController(IEmployeeService employeeService)
        {
            this.employeeService = employeeService;
        }

        [HttpGet("search")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<List<EmployeeSearchResultDto>>> Search([FromQuery] EmployeeSearchDto searchDto)
        {
            try
            {
                return await employeeService.Search(searchDto);
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

        [HttpGet("supervisors")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<List<EmployeeDto>>> GetSupervisors([FromQuery] int? departmentId)
        {
            try
            {
                return await employeeService.GetAllSupervisors(departmentId);
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

        [HttpGet("assignment/{employeeId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<EmployeeAssignmentResultDto>> GetEmployeeAssignment(int? employeeId)
        {
            try
            {
                if (!employeeId.HasValue)
                    return BadRequest(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Message = "Invalid request."
                    });

                var employeeAssignment = await employeeService.GetEmployeeAssignment(employeeId.Value);
                if (employeeAssignment is null)
                    return StatusCode(StatusCodes.Status404NotFound, new ApiMessageResponse
                    {
                        Status = StatusCodes.Status404NotFound,
                        Message = "Employee not found."
                    });

                return employeeAssignment;
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

        [HttpGet("details/{employeeId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<EmployeeDetailsResultDto>> GetEmployeeDetails(string employeeId)
        {
            try
            {
                var details = await employeeService.GetDetails(employeeId);
                if (details is null)
                    return NotFound(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status404NotFound,
                        Message = "Employee not found."
                    });

                return Ok(details);
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

        [HttpGet("details/search")]
        [Authorize(Roles = $"{nameof(UserRole.CEO)},{nameof(UserRole.HRSupervisor)},{nameof(UserRole.HREmployee)}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<List<EmployeeDetailsResultDto>>> SearchEmployees([FromQuery] EmployeeSearchDto searchDto)
        {
            try
            {
                return await employeeService.Search(searchDto.EmployeeID, searchDto.LastName);
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

        [HttpGet("{employeeId:int}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<Employee>> Get(int employeeId)
        {
            try
            {
                var employee = await employeeService.GetEmployee(employeeId);

                if (employee is null)
                    return NotFound(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status404NotFound,
                        Message = "Employee not found."
                    });

                return employee;
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

        [HttpGet("info/{employeeId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<PersonalInfoDto>> GetPersonalInfo(int employeeId)
        {
            try
            {
                var employee = await employeeService.GetPersonalInfo(employeeId);

                if (employee is null)
                    return NotFound(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status404NotFound,
                        Message = "Error fetching employee information."
                    });

                return employee;
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

        [HttpPost]
        [Authorize(Roles = $"{nameof(UserRole.CEO)},{nameof(UserRole.HRSupervisor)},{nameof(UserRole.HREmployee)}")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<ActionResult<ApiMessageResponse>> Create([FromBody] Employee employee)
        {
            try
            {
                if (employee is null)
                {
                    return BadRequest(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Message = "Invalid request."
                    });
                }

                employee = await employeeService.Create(employee);

                if (employee.Errors.Count > 0)
                    return BadRequest(new ApiErrorsResponse<ValidationError>
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Errors = employee.Errors
                    });

                return StatusCode(StatusCodes.Status201Created, new ApiMessageResponse
                {
                    Status = StatusCodes.Status201Created,
                    Message = "Employee created successfully."
                });
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new ApiMessageResponse
                {
                    Status = StatusCodes.Status500InternalServerError,
                    Message = "Something went wrong while processing your request. Please try again later."
                });
            }
        }


        [HttpPut]
        [Authorize(Roles = $"{nameof(UserRole.CEO)},{nameof(UserRole.HRSupervisor)},{nameof(UserRole.HREmployee)}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<ActionResult<ApiMessageResponse>> UpdateEmployee([FromBody] Employee employee)
        {
            try
            {
                if (employee is null || employee.ID == 0)
                {
                    return BadRequest(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Message = "Invalid request."
                    });
                }

                if (employee.SupervisorID.HasValue && employee?.SupervisorID.Value == employee?.ID)
                {
                    return Conflict(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status409Conflict,
                        Message = "Employee cannot be their own supervisor."
                    });
                }


                bool? isValid = await employeeService.CanReinstateEmployee(employee!);

                if (isValid is null)
                {
                    return NotFound(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status404NotFound,
                        Message = "Employee not found."
                    });
                }
                else if (!isValid.Value)
                {
                    return Conflict(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status409Conflict,
                        Message = "Status changes are not permitted for retired employees."
                    });
                }

                var updatedEmp = await employeeService.Update(employee!);
                if (updatedEmp is null)
                    return StatusCode(StatusCodes.Status500InternalServerError, new ApiMessageResponse
                    {
                        Status = StatusCodes.Status500InternalServerError,
                        Message = "Something went wrong while processing your request. Please try again later."
                    });

                if (updatedEmp.Errors.Count > 0)
                    return BadRequest(new ApiErrorsResponse<ValidationError>
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Errors = employee!.Errors
                    });

                return StatusCode(StatusCodes.Status200OK, new ApiMessageResponse
                {
                    Status = StatusCodes.Status200OK,
                    Message = "Employee updated successfully."
                });
            }
            catch (Exception ex)
            {
                if (ex is SqlException sqlEx && sqlEx.Number == 50001)
                {
                    return StatusCode(StatusCodes.Status409Conflict, new ApiMessageResponse
                    {
                        Status = StatusCodes.Status409Conflict,
                        Message = "Update failed. Please refresh the page."
                    });
                }

                return StatusCode(StatusCodes.Status500InternalServerError, new ApiMessageResponse
                {
                    Status = StatusCodes.Status500InternalServerError,
                    Message = "Something went wrong while processing your request. Please try again later."
                });
            }
        }

        [HttpPut("info")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<ActionResult<ApiMessageResponse>> UpdatePersonalInfo([FromBody] PersonalInfoDto info)
        {
            try
            {
                if (info is null || info.ID == 0)
                {
                    return BadRequest(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Message = "Invalid request."
                    });
                }

                var updatedEmp = await employeeService.UpdatePersonalInfo(info);

                if (updatedEmp is null)
                    return StatusCode(StatusCodes.Status500InternalServerError, new ApiMessageResponse
                    {
                        Status = StatusCodes.Status500InternalServerError,
                        Message = "Something went wrong while processing your request. Please try again later."
                    });

                if (updatedEmp.Errors.Count > 0)
                    return BadRequest(new ApiErrorsResponse<ValidationError>
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Errors = updatedEmp.Errors
                    });

                return StatusCode(StatusCodes.Status200OK, new ApiMessageResponse
                {
                    Status = StatusCodes.Status200OK,
                    Message = "Successfully updated employee information."
                });
            }
            catch (Exception ex)
            {
                if (ex is SqlException sqlEx && sqlEx.Number == 50001)
                {
                    return StatusCode(StatusCodes.Status409Conflict, new ApiMessageResponse
                    {
                        Status = StatusCodes.Status409Conflict,
                        Message = "Update failed. Please refresh the page."
                    });
                }

                return StatusCode(StatusCodes.Status500InternalServerError, new ApiMessageResponse
                {
                    Status = StatusCodes.Status500InternalServerError,
                    Message = "Something went wrong while processing your request. Please try again later."
                });
            }
        }
    }
}
