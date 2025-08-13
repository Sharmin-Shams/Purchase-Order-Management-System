using CodeNB.Api.Models;
using CodeNB.API.Interfaces;
using CodeNB.Model;
using CodeNB.Service;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace CodeNB.Api.Controllers
{
    [Route("api/auth")]
    [ApiController]
    public class AuthenticationController : ControllerBase
    {
        private readonly IAuthenticationService authService;
        private readonly ITokenService tokenService;
        private readonly IReviewService reviewService;
        public AuthenticationController(IAuthenticationService authenticationService,
            ITokenService tokenService, IReviewService reviewService)
        {
            this.authService = authenticationService;
            this.tokenService = tokenService;
            this.reviewService = reviewService;
        }

        [HttpPost("login")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<LoginResultDto>> Post([FromBody] LoginDto credentials)
        {
            try
            {
                if (credentials is null)
                    return BadRequest(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Message = "Invalid request."
                    });

                credentials = authService.ValidateCredentials(credentials);
                if (credentials.Errors.Count > 0)
                    return BadRequest(new ApiErrorsResponse<ValidationError>
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Errors = credentials.Errors
                    });

                var user = await authService.Login(credentials);
                if (user is null)
                    return Unauthorized(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status401Unauthorized,
                        Message = "Invalid login."
                    });


                user.Token = tokenService.CreateToken(user);
                user.ExpiresIn = 7 * 24 * 60 * 60;

                _ = Task.Run(async () =>
                {
                    try
                    {
                        var success = await reviewService.SendReminder();
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("Email reminder could not be sent. Please contact support.");
                        Console.WriteLine($"Error: {ex.Message}");
                    }
                });

                return Ok(user);
  
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
    }
}
