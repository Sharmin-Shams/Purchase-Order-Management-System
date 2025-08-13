using CodeNB.Api.Models;
using CodeNB.Model;
using CodeNB.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CodeNB.Api.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class ReviewsController : Controller
    {
        private readonly IReviewService reviewService;
        public ReviewsController(IReviewService reviewService)
        {
            this.reviewService = reviewService;
        }

        [HttpGet("pending")]
        [Authorize(Roles = $"{nameof(UserRole.CEO)},{nameof(UserRole.HRSupervisor)},{nameof(UserRole.RegularSupervisor)}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<ActionResult<List<EmployeesForReviewResultDto>>> GetPending([FromQuery] int? id)
        {
            try
            {
                return await reviewService.GetPendingEmployeesForReview(id) ?? [];
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

        [HttpGet("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<ActionResult<List<EmployeeReviewDto>>> GetAll(int id)
        {
            try
            {
                return await reviewService.GetReviews(id);
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

        [HttpPost]
        [Authorize(Roles = $"{nameof(UserRole.CEO)},{nameof(UserRole.HRSupervisor)},{nameof(UserRole.RegularSupervisor)}")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<ActionResult<ApiMessageResponse>> Create([FromBody] Review review)
        {
            try
            {
                if (review is null || review.EmployeeID == 0 ||
                    review.SupervisorID == 0 || review.Year == 0 || review.Quarter == 0)
                {
                    return BadRequest(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Message = "Invalid request."
                    });
                }

                if (review.SupervisorID == review.EmployeeID)
                {
                    return Conflict(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status409Conflict,
                        Message = "Supervisor cannot leave review to oneself. Nice try tho"
                    });
                }

                review = await reviewService.Create(review);

                if (review?.Errors.Count > 0)
                {
                    return BadRequest(new ApiErrorsResponse<ValidationError>
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Errors = review.Errors
                    });
                }

                if (review is null)
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, new ApiMessageResponse
                    {
                        Status = StatusCodes.Status500InternalServerError,
                        Message = "Something went wrong while processing your request. Please try again later."
                    });
                }

                return StatusCode(StatusCodes.Status201Created, new ApiMessageResponse
                {
                    Status = StatusCodes.Status201Created,
                    Message = "Review successfully created."
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

        [HttpPut("read/{id}")]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        public async Task<ActionResult<bool>> MarkAsRead(int id)
        {
            try
            {
                var success = await reviewService.MarkReviewAsRead(id);
                if (!success)
                    return NotFound(new ApiMessageResponse { Status = 404, Message = "Review not found." });
                return NoContent();
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
