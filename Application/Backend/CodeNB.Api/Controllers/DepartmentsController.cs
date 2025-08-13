using CodeNB.Api.Models;
using CodeNB.Model;
using CodeNB.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace CodeNB.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class DepartmentsController : ControllerBase
    {
        private readonly IDepartmentService departmentService;

        public DepartmentsController(IDepartmentService departmentService)
        {
            this.departmentService = departmentService;
        }

        [HttpGet]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<ActionResult<List<DepartmentDto>>> Get()
        {
            try
            {
                return await departmentService.GetAll();
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

        [HttpGet("details")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<ActionResult<List<Department>>> GetWithDetails()
        {
            try
            {
                return await departmentService.GetAllWithDetails();
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
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [Authorize(Roles = $"{nameof(UserRole.CEO)},{nameof(UserRole.HRSupervisor)},{nameof(UserRole.HREmployee)}")]
        public async Task<ActionResult<ApiMessageResponse>> Create([FromBody] Department department)
        {
            try
            {
                if (department is null)
                {
                    return BadRequest(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Message = "Invalid request."
                    });
                }

                department = await departmentService.Create(department);

                if (department.Errors.Count > 0)
                    return BadRequest(new ApiErrorsResponse<ValidationError>
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Errors = department.Errors
                    });

                return StatusCode(StatusCodes.Status201Created, new ApiMessageResponse
                {
                    Status = StatusCodes.Status201Created,
                    Message = "Department created successfully."
                });
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

        [HttpPut]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [Authorize(Roles = $"{nameof(UserRole.CEO)},{nameof(UserRole.HRSupervisor)},{nameof(UserRole.HREmployee)}")]
        public async Task<ActionResult<ApiMessageResponse>> Update([FromBody] Department department)
        {
            try
            {
                if (department is null || department.ID == 0)
                    return BadRequest(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Message = "Invalid request."
                    });

                var dept = await departmentService.Update(department);

                if (dept?.Errors.Count > 0)
                {
                    var is404 = dept.Errors[0].Field == "404";
                    if (is404)
                    {
                        return NotFound(new ApiMessageResponse
                        {
                            Status = StatusCodes.Status404NotFound,
                            Message = dept.Errors[0].Description
                        });
                    }

                    return BadRequest(new ApiErrorsResponse<ValidationError>
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Errors = department.Errors
                    });
                }

                if (dept is null)
                {
                    return StatusCode(StatusCodes.Status409Conflict, new ApiMessageResponse
                    {
                        Status = StatusCodes.Status409Conflict,
                        Message = "There was a problem updating the department."
                    });
                }

                return Ok(new ApiMessageResponse
                {
                    Status = StatusCodes.Status200OK,
                    Message = "Department updated successfully."
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

        [HttpDelete]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        [Authorize(Roles = $"{nameof(UserRole.CEO)},{nameof(UserRole.HRSupervisor)},{nameof(UserRole.HREmployee)}")]
        public async Task<ActionResult<ApiMessageResponse>> Delete([FromBody] Department department)
        {
            try
            {
                if (department is null || department.ID == 0)
                    return BadRequest(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Message = "Invalid request."
                    });

                if (!await departmentService.Delete(department))
                {
                    if (department.Errors.Count > 0)
                        return StatusCode(StatusCodes.Status409Conflict, new ApiMessageResponse
                        {
                            Status = StatusCodes.Status409Conflict,
                            Message = department.Errors.FirstOrDefault()?.Description
                        });

                    return StatusCode(StatusCodes.Status409Conflict, new ApiMessageResponse
                    {
                        Status = StatusCodes.Status409Conflict,
                        Message = "There was a problem deleting the department."
                    });
                }

                return Ok(new ApiMessageResponse
                {
                    Status = StatusCodes.Status200OK,
                    Message = "Department deleted successfully."
                });
            }
            catch (Exception ex)
            {
                if (ex is SqlException sqlEx && sqlEx.Number == 50001)
                {
                    return StatusCode(StatusCodes.Status409Conflict, new ApiMessageResponse
                    {
                        Status = StatusCodes.Status409Conflict,
                        Message = "Delete failed. Please refresh the page."
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